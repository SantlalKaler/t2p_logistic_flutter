package taste2plates.app.logistic

import android.app.*
import android.content.*
import android.content.pm.ServiceInfo
import android.database.sqlite.SQLiteDatabase
import android.location.Location
import android.net.*
import android.os.*
import android.security.keystore.KeyGenParameterSpec
import android.security.keystore.KeyProperties
import android.util.Base64
import com.google.android.gms.location.*
import org.json.JSONArray
import org.json.JSONObject
import java.net.HttpURLConnection
import java.net.URL
import java.security.KeyStore
import java.text.SimpleDateFormat
import java.util.Date
import java.util.Locale
import java.util.TimeZone
import java.util.concurrent.Executors
import javax.crypto.Cipher
import javax.crypto.KeyGenerator
import javax.crypto.SecretKey
import javax.crypto.spec.GCMParameterSpec

/** One recorder/uploader, independent of the Flutter activity and engine. */
class DutyTrackingService : Service() {
    companion object {
        private const val PREFS = "t2p_duty_service"
        private const val KEY = "t2p_duty_service_key"
        private const val CHANNEL = "t2p_active_duty"
        private const val NOTIFICATION = 4201
        @Volatile private var instance: DutyTrackingService? = null
        @Volatile var warning: String = ""
            private set

        private fun key(): SecretKey {
            val store = KeyStore.getInstance("AndroidKeyStore").apply { load(null) }
            (store.getKey(KEY, null) as? SecretKey)?.let { return it }
            return KeyGenerator.getInstance(KeyProperties.KEY_ALGORITHM_AES, "AndroidKeyStore").apply {
                init(KeyGenParameterSpec.Builder(KEY, KeyProperties.PURPOSE_ENCRYPT or KeyProperties.PURPOSE_DECRYPT)
                    .setBlockModes(KeyProperties.BLOCK_MODE_GCM)
                    .setEncryptionPaddings(KeyProperties.ENCRYPTION_PADDING_NONE).build())
            }.generateKey()
        }

        // Persist the bearer token encrypted with a device-bound key for sticky restart.
        fun saveConfig(context: Context, json: String) {
            val next = JSONObject(json)
            instance?.config?.let {
                if (it.optString("session") != next.optString("session") || it.optString("owner") != next.optString("owner")) stop(context)
            }
            val cipher = Cipher.getInstance("AES/GCM/NoPadding").apply { init(Cipher.ENCRYPT_MODE, key()) }
            val encrypted = cipher.iv + cipher.doFinal(json.toByteArray(Charsets.UTF_8))
            check(context.getSharedPreferences(PREFS, MODE_PRIVATE).edit()
                .putString("config", Base64.encodeToString(encrypted, Base64.NO_WRAP)).commit())
        }

        private fun readConfig(context: Context): JSONObject? {
            val saved = context.getSharedPreferences(PREFS, MODE_PRIVATE).getString("config", null) ?: return null
            val bytes = Base64.decode(saved, Base64.NO_WRAP)
            val cipher = Cipher.getInstance("AES/GCM/NoPadding").apply {
                init(Cipher.DECRYPT_MODE, key(), GCMParameterSpec(128, bytes.copyOfRange(0, 12)))
            }
            return JSONObject(String(cipher.doFinal(bytes.copyOfRange(12, bytes.size)), Charsets.UTF_8))
        }

        fun stop(context: Context) {
            context.getSharedPreferences(PREFS, MODE_PRIVATE).edit().remove("config").commit()
            instance?.halt()
            context.stopService(Intent(context, DutyTrackingService::class.java))
        }

        fun requestSync() { instance?.enqueueUpload() }
        fun refreshRunningConfig(json: String): Boolean {
            val service = instance ?: return false
            if (!service.active) return false
            service.config = JSONObject(json)
            return true
        }
        fun pause() {
            instance?.let { service ->
                service.recording = false
                service.fused.removeLocationUpdates(service.locationCallback)
                warning = "Duty is OFF. Saved points and Stop are waiting to sync."
                service.showNotification()
                service.enqueueUpload()
            }
        }
    }

    private val handler = Handler(Looper.getMainLooper())
    private val worker = Executors.newSingleThreadExecutor()
    private lateinit var fused: FusedLocationProviderClient
    @Volatile private var config: JSONObject? = null
    private var db: SQLiteDatabase? = null
    private var lastSaved: Location? = null
    private val utc = SimpleDateFormat("yyyy-MM-dd'T'HH:mm:ss.SSS'Z'", Locale.US).apply { timeZone = TimeZone.getTimeZone("UTC") }
    private var wakeLock: PowerManager.WakeLock? = null
    private var network: ConnectivityManager? = null
    @Volatile private var active = false
    @Volatile private var recording = false
    @Volatile private var connection: HttpURLConnection? = null
    @Volatile private var uploading = false
    private var retryAt = 0L
    private val tick = object : Runnable {
        override fun run() {
            if (!active) return
            enqueueUpload()
            handler.postDelayed(this, 60_000)
        }
    }
    private val networkCallback = object : ConnectivityManager.NetworkCallback() {
        override fun onAvailable(network: Network) { enqueueUpload() }
    }
    private val locationCallback = object : LocationCallback() {
        override fun onLocationResult(result: LocationResult) {
            for (location in result.locations) {
                if (!active || !recording) break
                // No accuracy/drift filtering here: the server owns distance calculation.
                val previous = lastSaved
                if (DutyRecordingPolicy.shouldSave(previous != null,
                    previous?.let { location.distanceTo(it) } ?: 0f,
                    previous?.let { location.time - it.time } ?: 0L)) {
                    record(location)
                }
            }
        }
        override fun onLocationAvailability(availability: LocationAvailability) {
            if (!recording) return
            warning = if (availability.isLocationAvailable) "" else "GPS unavailable. Enable GPS and precise location to record your full route."
            if (active) showNotification()
        }
    }

    override fun onBind(intent: Intent?) = null

    override fun onCreate() {
        super.onCreate()
        instance = this
        fused = LocationServices.getFusedLocationProviderClient(this)
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        try {
            val restored = readConfig(this) ?: run { stopSelf(); return START_NOT_STICKY }
            showNotification()
            if (active) {
                // A foreground reconciliation refreshes credentials without resetting the recorder.
                check(config?.getString("session") == restored.getString("session")) { "Another duty is still tracking" }
                config = restored
                return START_STICKY
            }
            config = restored
            db = SQLiteDatabase.openDatabase(restored.getString("databasePath"), null, SQLiteDatabase.OPEN_READWRITE)
            val state = readState(restored)
            if (state?.optJSONObject("session")?.optString("session_id") == restored.getString("session") &&
                state.optJSONObject("session")?.optString("status") == "off" && pendingStop(restored) == null) {
                stop(this)
                return START_NOT_STICKY
            }
            restoreLastSaved()
            active = true
            recording = pendingStop(restored) == null
            warning = if (recording) "" else "Duty is OFF. Saved points and Stop are waiting to sync."
            wakeLock = (getSystemService(POWER_SERVICE) as PowerManager)
                .newWakeLock(PowerManager.PARTIAL_WAKE_LOCK, "T2P:DutyTracking").apply { acquire() }
            val request = LocationRequest.Builder(Priority.PRIORITY_HIGH_ACCURACY, 10_000)
                .setMinUpdateIntervalMillis(5_000)
                .setMinUpdateDistanceMeters(0f)
                .setWaitForAccurateLocation(false)
                .setMaxUpdateDelayMillis(10_000)
                .build()
            if (recording) fused.requestLocationUpdates(request, locationCallback, Looper.getMainLooper())
                .addOnFailureListener {
                    warning = "Location tracking interrupted. Check GPS and location permissions."
                    showNotification()
                }
            network = getSystemService(CONNECTIVITY_SERVICE) as ConnectivityManager
            network?.registerDefaultNetworkCallback(networkCallback)
            handler.post(tick)
            showNotification()
            return START_STICKY
        } catch (e: Exception) {
            warning = "Unable to start duty tracking. Open T2P and check location permissions."
            halt()
            return START_NOT_STICKY
        }
    }

    private fun showNotification() {
        val manager = getSystemService(NOTIFICATION_SERVICE) as NotificationManager
        if (Build.VERSION.SDK_INT >= 26) manager.createNotificationChannel(
            NotificationChannel(CHANNEL, "Duty tracking", NotificationManager.IMPORTANCE_LOW))
        val openApp = packageManager.getLaunchIntentForPackage(packageName)
        val pending = PendingIntent.getActivity(this, 0, openApp, PendingIntent.FLAG_IMMUTABLE or PendingIntent.FLAG_UPDATE_CURRENT)
        val builder = if (Build.VERSION.SDK_INT >= 26) Notification.Builder(this, CHANNEL) else Notification.Builder(this)
        val notification = builder.setContentTitle(if (recording || config == null) "T2P: You are on duty" else "T2P: Duty sync pending")
            .setContentText(warning.ifEmpty { "Location tracking is active" })
            .setSmallIcon(resources.getIdentifier("ic_duty_notification", "drawable", packageName))
            .setContentIntent(pending).setOngoing(true).build()
        if (Build.VERSION.SDK_INT >= 29) startForeground(NOTIFICATION, notification, ServiceInfo.FOREGROUND_SERVICE_TYPE_LOCATION)
        else startForeground(NOTIFICATION, notification)
    }

    private fun restoreLastSaved() {
        val c = config ?: return
        val saved = getSharedPreferences(PREFS, MODE_PRIVATE).getString("last:${c.getString("session")}", null) ?: return
        val p = JSONObject(saved)
        lastSaved = Location("saved").apply {
            latitude = p.getDouble("lat"); longitude = p.getDouble("lng")
            time = utc.parse(p.getString("at"))!!.time
        }
    }

    private fun record(location: Location) {
        val c = config ?: return
        if (pendingStop(c) != null) {
            recording = false
            fused.removeLocationUpdates(locationCallback)
            return
        }
        // Writes happen synchronously before returning the callback, so Stop never
        // overtakes a queued point. SQLite serializes native and sqflite access.
        val point = JSONObject().put("lat", location.latitude).put("lng", location.longitude)
            .put("at", utc.format(Date(location.time))).put("accuracy", location.accuracy.toDouble())
        try {
            db?.insertWithOnConflict("points", null, ContentValues().apply {
                put("owner", c.getString("owner")); put("session", c.getString("session"))
                put("at", point.getString("at")); put("body", point.toString())
            }, SQLiteDatabase.CONFLICT_IGNORE)
            lastSaved = Location(location)
            getSharedPreferences(PREFS, MODE_PRIVATE).edit()
                .putString("last:${c.getString("session")}", point.toString()).apply()
        } catch (e: Exception) {
            warning = "Unable to save GPS point. Check available phone storage."
            showNotification()
        }
    }

    @Synchronized private fun enqueueUpload() {
        if (!active || uploading || System.currentTimeMillis() < retryAt) return
        uploading = true
        worker.execute {
            try { upload() } catch (_: Exception) {
                // Keep every unsent row; retry on the next minute or network event.
            } finally { uploading = false }
        }
    }

    private fun upload() {
        var serverEnded = false
        while (active) {
            val c = config ?: return
            val ids = mutableListOf<Long>()
            val points = JSONArray()
            db?.query("points", arrayOf("id", "body"), "owner = ? AND session = ?",
                arrayOf(c.getString("owner"), c.getString("session")), null, null, "at ASC, id ASC", "500")?.use { cursor ->
                while (cursor.moveToNext()) { ids.add(cursor.getLong(0)); points.put(JSONObject(cursor.getString(1))) }
            }
            val stopRequest = pendingStop(c)
            val ending = stopRequest != null && ids.size < 500
            if (!active) return
            if (ids.isEmpty() && !ending) {
                if (serverEnded) handler.post { if (active && instance === this) stop(this) }
                return
            }
            val endpoint = if (ending) "off" else "points"
            val http = URL(c.getString("baseUrl").trimEnd('/') + "/v1/duty/$endpoint").openConnection() as HttpURLConnection
            connection = http
            try {
                http.requestMethod = "POST"
                http.connectTimeout = 20_000; http.readTimeout = 45_000
                http.setRequestProperty("Authorization", "Bearer ${c.getString("token")}")
                http.setRequestProperty("Content-Type", "application/json")
                http.doOutput = true
                val body = (if (ending) JSONObject(stopRequest!!.toString()) else JSONObject())
                    .put("session_id", c.getString("session")).put("points", points)
                http.outputStream.use { it.write(body.toString().toByteArray(Charsets.UTF_8)) }
                val code = http.responseCode
                if (code != 200) {
                    if (code == 429) retryAt = System.currentTimeMillis() + (http.getHeaderField("Retry-After")?.toLongOrNull() ?: 60) * 1000
                    if (code == 401) {
                        warning = "Duty sync needs login. Open T2P to log in again."
                        handler.post { showNotification() }
                    }
                    return
                }
                val response = JSONObject(http.inputStream.bufferedReader().use { it.readText() })
                if (response.optString("status") != "success") return
                if (ids.isNotEmpty()) db?.delete("points", "id IN (${ids.joinToString(",")})", null)
                if (ending || response.optJSONObject("data")?.optString("status") == "off") {
                    // Clear only this Stop; never overwrite a newer duty written by Flutter.
                    db?.beginTransaction()
                    try {
                        val state = readState(c)
                        if (state?.optJSONObject("stop")?.optString("session_id") == c.getString("session")) {
                            if (ending) state.put("stop", JSONObject.NULL)
                            state.put("session", response.getJSONObject("data"))
                            db?.update("state", ContentValues().apply { put("body", state.toString()) }, "owner = ?", arrayOf(c.getString("owner")))
                        } else if (state?.optJSONObject("session")?.optString("session_id") == c.getString("session")) {
                            state.put("session", response.getJSONObject("data"))
                            db?.update("state", ContentValues().apply { put("body", state.toString()) }, "owner = ?", arrayOf(c.getString("owner")))
                        }
                        db?.setTransactionSuccessful()
                    } finally { db?.endTransaction() }
                }
                if (ending) {
                    handler.post { if (active && instance === this) stop(this) }
                    return
                }
                if (response.optJSONObject("data")?.optString("status") == "off") {
                    serverEnded = true
                    recording = false
                    handler.post { fused.removeLocationUpdates(locationCallback) }
                    // Drain all pre-OFF points before shutting down the uploader.
                }
            } finally { http.disconnect(); connection = null }
        }
    }

    private fun readState(c: JSONObject): JSONObject? {
        db?.query("state", arrayOf("body"), "owner = ?", arrayOf(c.getString("owner")), null, null, null)?.use {
            if (it.moveToFirst()) return JSONObject(it.getString(0))
        }
        return null
    }

    private fun pendingStop(c: JSONObject): JSONObject? = readState(c)?.optJSONObject("stop")?.takeIf {
        it.optString("session_id") == c.getString("session")
    }

    private fun halt() {
        active = false
        recording = false
        handler.removeCallbacksAndMessages(null)
        fused.removeLocationUpdates(locationCallback)
        connection?.disconnect()
        try { network?.unregisterNetworkCallback(networkCallback) } catch (_: Exception) { }
        network = null
        wakeLock?.let { if (it.isHeld) it.release() }
        wakeLock = null
        stopForeground(STOP_FOREGROUND_REMOVE)
        stopSelf()
    }

    override fun onDestroy() {
        halt()
        worker.shutdown()
        // Close only after the in-flight upload has left the shared SQLite handle.
        Thread { worker.awaitTermination(60, java.util.concurrent.TimeUnit.SECONDS); db?.close() }.start()
        if (instance === this) instance = null
        super.onDestroy()
    }
}
