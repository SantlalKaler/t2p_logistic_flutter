package taste2plates.app.logistic

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import android.content.Intent
import android.os.Build

class MainActivity: FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "t2p/duty_tracking")
            .setMethodCallHandler { call, result ->
                try {
                    when (call.method) {
                        "start" -> {
                            val config = org.json.JSONObject(call.arguments as Map<*, *>).toString()
                            DutyTrackingService.saveConfig(this, config)
                            if (!DutyTrackingService.refreshRunningConfig(config)) {
                                val intent = Intent(this, DutyTrackingService::class.java)
                                if (Build.VERSION.SDK_INT >= 26) startForegroundService(intent) else startService(intent)
                            }
                            result.success(null)
                        }
                        "stop" -> {
                            DutyTrackingService.stop(this)
                            result.success(null)
                        }
                        "pause" -> {
                            DutyTrackingService.pause()
                            result.success(null)
                        }
                        "sync" -> {
                            DutyTrackingService.requestSync()
                            result.success(null)
                        }
                        "warning" -> result.success(DutyTrackingService.warning)
                        else -> result.notImplemented()
                    }
                } catch (e: Exception) {
                    result.error("duty_tracking", e.message, null)
                }
            }
    }
}
