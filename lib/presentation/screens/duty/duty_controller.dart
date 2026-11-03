import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart' hide ServiceStatus;
import 'package:connectivity_plus/connectivity_plus.dart';

import '../../../data/api_services.dart';
import '../../../data/duty_store.dart';
import '../../../data/duty_requests.dart';
import '../../../data/duty_background.dart';
import '../../../data/duty_recording.dart';
import '../../theme/resource/uri_constants.dart';
import '../../../domain/Model/duty.dart';
import '../../../domain/Model/expense/expense_v1.dart';
import '../../controllers/user_controller.dart';
import '../expense_management/expense_controller.dart';
import '../expense_management/components/expense_dialog.dart';
import 'duty_actual_km.dart';

class DutyController extends GetxController with WidgetsBindingObserver {
  final ApiService api;
  final DutyStore store;
  DutyController({
    ApiService? api,
    DutyStore? store,
    DutyBackground? background,
  }) : api = api ?? ApiService(),
       store = store ?? DutyStore(),
       _background = background ?? DutyBackground();
  DutySession? session;
  Map<String, dynamic>? pendingStop;
  bool busy = false, ready = false, refreshing = false;
  int _intentRevision = 0;
  String error = '', warning = '';
  DateTime? _retryAt;
  String _owner = '';
  Timer? _uploadTimer, _readTimer;
  bool _reading = false;
  StreamSubscription<Position>? _positions;
  StreamSubscription<ServiceStatus>? _services;
  StreamSubscription<List<ConnectivityResult>>? _connectivity;
  final DutyBackground _background;
  DateTime? _lastUpload;
  Position? _last, _lastSaved;
  Future<void> _writes = Future.value();
  Future<void>? _sync;
  bool _actualKmOpen = false;
  bool get supported =>
      !kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.android ||
          defaultTargetPlatform == TargetPlatform.iOS);
  bool get on => session?.isOn == true && pendingStop == null;
  bool get orderControls => [
    'pickup_boy',
    'pickup_partner',
    'delivery_boy',
    'delivery_partner',
  ].contains(Get.find<UserController>().userType);

  @override
  void onInit() {
    super.onInit();
    WidgetsBinding.instance.addObserver(this);
    _uploadTimer = Timer.periodic(const Duration(minutes: 1), (_) {
      if (_owner.isNotEmpty && !busy) unawaited(reconcile(silent: true));
    });
    _connectivity = Connectivity().onConnectivityChanged.listen((results) {
      if (results.any((r) => r != ConnectivityResult.none) &&
          _owner.isNotEmpty) {
        unawaited(reconcile(silent: true));
      }
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) unawaited(reconcile());
  }

  Future<Map<String, dynamic>> request(
    String suffix, {
    dynamic data,
    Map<String, dynamic>? query,
  }) async {
    if (_retryAt != null && DateTime.now().isBefore(_retryAt!)) {
      throw ExpenseApiException(429, 'Please wait before retrying duty sync.');
    }
    try {
      final raw = await api.expenseRequest(
        'v1/duty/$suffix',
        method: data == null ? 'GET' : 'POST',
        data: data,
        query: query,
      );
      if ((suffix == 'points' || suffix == 'off') && raw.statusCode != 200) {
        throw ExpenseApiException(
          raw.statusCode,
          'Duty sync was not acknowledged. Saved data will retry.',
        );
      }
      final response = expenseMap(raw.data);
      if (kDebugMode) {
        final duties = response['data'] is List
            ? expenseMaps(response['data']).take(5)
            : [expenseMap(response['data'])];
        for (final duty in duties.where((d) => d.isNotEmpty)) {
          String addressState(String field) {
            if (!duty.containsKey(field)) return 'absent';
            if (duty[field] == null) return 'null';
            if (duty[field] is! String) return 'unexpected_type';
            return (duty[field] as String).trim().isEmpty ? 'empty' : 'present';
          }

          debugPrint(
            '[Duty API] $suffix session=${duty['session_id']} status=${duty['status']} points=${duty['points_count']} start_address=${addressState('start_address')} end_address=${addressState('end_address')} fields=${duty.keys.join(',')}',
          );
        }
      }
      return response;
    } on ExpenseApiException catch (e) {
      if (e.statusCode == 429) {
        _retryAt = DateTime.now().add(Duration(seconds: e.retryAfter ?? 60));
      }
      rethrow;
    }
  }

  Future<void> _persist() =>
      store.write(_owner, {'session': session?.json, 'stop': pendingStop});

  Future<void> reconcile({bool silent = false}) async {
    if (!supported ||
        busy ||
        refreshing ||
        !Get.find<UserController>().isLoggedIn) {
      return;
    }
    refreshing = true;
    final revision = _intentRevision;
    update();
    try {
      final owner = Get.find<UserController>().userId;
      if (_owner != owner) {
        await suspend();
        _owner = owner;
        final state = await store.read(owner);
        session = state['session'] == null
            ? null
            : DutySession(expenseMap(state['session']));
        pendingStop = state['stop'] == null ? null : expenseMap(state['stop']);
      }
      // Restore local tracking even when the server cannot be reached.
      if (session != null || pendingStop != null) ready = true;
      update();
      if (on) await _track();
      try {
        await sync();
      } on ExpenseApiException catch (e) {
        // A stale outbox must not prevent checking the server's current duty.
        if (e.statusCode != 404) rethrow;
        warning = e.message;
      }
      final previous = session;
      final response = await request('me');
      if (_owner != owner || revision != _intentRevision) return;
      session = response['data'] == null
          ? null
          : DutySession(expenseMap(response['data']));
      if (pendingStop != null && session?.id != pendingStop!['session_id']) {
        // The requested duty is no longer running. Preserve any unsent points.
        pendingStop = null;
      }
      ready = true;
      error = '';
      await _persist();
      if (on) {
        await _track();
      } else {
        await _stopTracking();
        if (previous?.isOn == true || previous?.needsActualKm == true) {
          final history = await request('history', query: {'limit': 100});
          final closed = expenseMaps(history['data'])
              .where((row) => '${row['session_id']}' == previous!.id);
          if (closed.isNotEmpty) {
            unawaited(enterActualKm(DutySession(closed.first)));
          }
        }
      }
    } catch (e) {
      error = '$e';
    } finally {
      refreshing = false;
      update();
    }
  }

  Future<Position> _location() async {
    if (!await Geolocator.isLocationServiceEnabled()) {
      throw Exception('Turn on GPS to start duty.');
    }
    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      throw Exception('Allow location access in Settings to start duty.');
    }
    return Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        timeLimit: Duration(seconds: 20),
      ),
    );
  }

  Future<void> start({String? order}) async {
    if (busy || refreshing || !supported || !ready || on) return;
    final accepted = await Get.dialog<bool>(
      ExpenseDialog(
        title: 'Location during duty',
        icon: Icons.location_on_outlined,
        content: const Text(
          'T2P collects your location while duty is ON, including when the app is in the background or the screen is locked, to record your route and calculate duty kilometres. Tracking stops when you turn duty OFF.',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Get.back(result: true),
            child: const Text('Continue'),
          ),
        ],
      ),
    );
    if (accepted != true || busy || refreshing || on) return;
    _intentRevision++;
    busy = true;
    error = '';
    bool recover = false;
    update();
    try {
      try {
        await sync(); // A queued Stop must reach the server before another ON.
      } on ExpenseApiException catch (e) {
        if (e.statusCode != 404 || pendingStop != null) rethrow;
      }
      final position = await _location();
      final addressResponse = await request(
        'address',
        query: {'lat': position.latitude, 'lng': position.longitude},
      );
      final address = expenseMap(addressResponse['data'])['address'];
      final confirmed = await Get.dialog<bool>(
        ExpenseDialog(
          title: 'Confirm duty start',
          icon: Icons.location_on_outlined,
          content: Text(
            address == null || '$address'.trim().isEmpty
                ? 'Address unavailable. Start duty at your current GPS location?'
                : 'Start duty from:\n$address',
          ),
          actions: [
            TextButton(
              onPressed: () => Get.back(result: false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Get.back(result: true),
              child: const Text('Confirm'),
            ),
          ],
        ),
      );
      if (confirmed != true) return;
      if (defaultTargetPlatform == TargetPlatform.android) {
        await Permission.notification.request();
      }
      final response = await request(
        'on',
        data: {
          'lat': position.latitude,
          'lng': position.longitude,
          'accuracy': position.accuracy,
          'order': ?order,
        },
      );
      session = DutySession(expenseMap(response['data']));
      await _persist();
      _last = position;
      await _track();
      if (defaultTargetPlatform == TargetPlatform.android &&
          Get.context != null) {
        Get.snackbar(
          'Keep duty tracking running',
          'Allow unrestricted battery use for T2P in your phone settings, especially on Xiaomi, Oppo, Vivo and Realme phones.',
          mainButton: TextButton(
            onPressed: openAppSettings,
            child: const Text('Settings'),
          ),
          duration: const Duration(seconds: 8),
        );
      }
    } catch (e) {
      error = '$e';
      recover = e is ExpenseApiException && e.statusCode == 404;
    } finally {
      busy = false;
      update();
      if (recover) await reconcile();
    }
  }

  Future<void> stop() async {
    if (busy || !on) return;
    _intentRevision++;
    busy = true;
    final stoppedAt = DateTime.now().toUtc();
    bool recover = false;
    update();
    try {
      // Persist the user's intent before network activity or cancelling tracking.
      pendingStop = dutyStopRequest(
        sessionId: session!.id,
        tappedAt: stoppedAt,
        lastPosition: _last,
      );
      await _persist();
      update();
      await _stopTracking(preserveStop: true);
      await sync();
      if (pendingStop != null) await sync();
    } catch (e) {
      recover = e is ExpenseApiException && e.statusCode == 404;
      error = pendingStop != null
          ? 'Duty is OFF on this phone. Stop is saved and will retry automatically. $e'
          : 'Duty ended. Some GPS points are still waiting to sync. $e';
    } finally {
      busy = false;
      update();
      if (recover) await reconcile();
    }
  }

  Future<void> delivered(String order) async {
    if (session?.matches(order) != true || !on) return;
    // Delivery is already committed; wait for an in-flight upload/reconciliation.
    while (busy) {
      await Future<void>.delayed(const Duration(milliseconds: 100));
    }
    if (session?.matches(order) == true && on) await stop();
  }

  Future<void> _track() async {
    if (_positions != null || !on) return;
    if (!await Geolocator.isLocationServiceEnabled() ||
        ![
          LocationPermission.always,
          LocationPermission.whileInUse,
        ].contains(await Geolocator.checkPermission())) {
      warning = 'GPS or location permission is off. Enable it to record your full route.';
      return;
    }
    if (defaultTargetPlatform == TargetPlatform.android) {
      // Native service persists and uploads even if the Flutter engine is gone.
      await _background.start(
        owner: _owner,
        session: session!.id,
        token: await api.authController.readAccessToken(),
        baseUrl: URIConstants.baseURI,
        databasePath: (await store.database).path,
      );
      warning = await _background.warning();
      return;
    }
    final settings = AppleSettings(
      accuracy: LocationAccuracy.best,
      distanceFilter: 0,
      pauseLocationUpdatesAutomatically: false,
      showBackgroundLocationIndicator: true,
      allowBackgroundLocationUpdates: true,
    );
    _positions = Geolocator.getPositionStream(locationSettings: settings).listen(
      _recordPosition,
      onError: (Object e) {
        warning =
            'Location tracking interrupted. Check GPS and location permissions. $e';
        unawaited(_positions?.cancel());
        _positions = null;
        update();
      },
    );
    _readTimer?.cancel();
    _readTimer = Timer.periodic(const Duration(seconds: 10), (_) async {
      if (_reading || !on) return;
      _reading = true;
      final id = session!.id;
      try {
        final position = await Geolocator.getCurrentPosition(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.high,
            timeLimit: Duration(seconds: 10),
          ),
        );
        if (on && session?.id == id) _recordPosition(position);
      } catch (_) {
        if (on) {
          warning = 'GPS unavailable. Check location permissions and GPS.';
          update();
        }
      } finally {
        _reading = false;
      }
    });
    _services ??= Geolocator.getServiceStatusStream().listen((status) {
      warning = status == ServiceStatus.disabled
          ? 'GPS is off. Enable it to record your full route.'
          : '';
      update();
    });
  }

  void _recordPosition(Position position) {
    if (!on) return;
    _last = position;
    final owner = _owner, id = session!.id;
    // Decide inside the serialized write queue so a failed disk write never
    // advances the last-saved fix or silently loses the next eligible point.
    _writes = _writes
        .then((_) async {
          if (!shouldSaveDutyPoint(position, _lastSaved)) return;
          await store.add(owner, id, {
            'lat': position.latitude,
            'lng': position.longitude,
            'at': position.timestamp.toUtc().toIso8601String(),
            'accuracy': position.accuracy,
          });
          _lastSaved = position;
          if (warning.isNotEmpty) {
            warning = '';
            update();
          }
        })
        .catchError((Object e) {
          warning = 'Unable to save GPS point: $e';
          update();
        });
    _syncFromLocation();
  }

  // iOS location callbacks wake the app in the background; do not depend only
  // on a UI Timer for uploading while locked.
  void _syncFromLocation() {
    final now = DateTime.now();
    if (_lastUpload != null &&
        now.difference(_lastUpload!) < const Duration(minutes: 1)) {
      return;
    }
    _lastUpload = now;
    unawaited(
      sync().catchError((Object e) {
        warning = 'GPS points saved. Upload will retry. $e';
        update();
      }),
    );
  }

  Future<void> _stopTracking({bool preserveStop = false}) async {
    if (supported && defaultTargetPlatform == TargetPlatform.android) {
      if (preserveStop) {
        await _background.pause();
      } else {
        await _background.stop();
      }
    }
    _readTimer?.cancel();
    _readTimer = null;
    await _positions?.cancel();
    _positions = null;
    await _services?.cancel();
    _services = null;
    await _writes;
    _last = null;
    _lastSaved = null;
    _lastUpload = null;
    warning = '';
  }

  Future<void> sync() => _sync ??= _flush().whenComplete(() => _sync = null);
  Future<void> _flush() async {
    final owner = _owner;
    if (owner.isEmpty) return;
    await _writes;
    DutySession? stopped;
    if (pendingStop != null) {
      final stop = Map<String, dynamic>.from(pendingStop!);
      var rows = await store.batch(owner, session: '${stop['session_id']}');
      // OFF only accepts up to 500 points. Drain a larger offline backlog first,
      // preserving the user's original Stop timestamp throughout retries.
      while (rows.length == 500) {
        await request(
          'points',
          data: {
            'session_id': stop['session_id'],
            'points': rows.map(DutyStore.point).toList(),
          },
        );
        if (_owner != owner) return;
        await store.acknowledge(rows);
        rows = await store.batch(owner, session: '${stop['session_id']}');
      }
      final response = await request(
        'off',
        data: {...stop, 'points': rows.map(DutyStore.point).toList()},
      );
      if (_owner != owner) return;
      await store.acknowledge(rows);
      session = DutySession(expenseMap(response['data']));
      pendingStop = null;
      await _persist();
      await _stopTracking();
      await _refreshCash();
      stopped = session!;
    }
    // A batch contains one session; older, already stopped sessions can still sync.
    final missingSessions = <String>[];
    ExpenseApiException? missingError;
    while (_owner == owner) {
      var rows = await store.batch(owner, excludeSessions: missingSessions);
      if (rows.isEmpty) break;
      final id = rows.first['session'] as String;
      rows = rows.where((row) => row['session'] == id).toList();
      final Map<String, dynamic> response;
      try {
        response = await request(
          'points',
          data: {
            'session_id': id,
            'points': rows.map(DutyStore.point).toList(),
          },
        );
      } on ExpenseApiException catch (e) {
        if (e.statusCode != 404) rethrow;
        // Preserve missing-session points without starving other duties.
        missingSessions.add(id);
        missingError = e;
        continue;
      }
      if (_owner != owner) return;
      await store.acknowledge(
        rows,
      ); // Includes rejected points: never retry them.
      final returned = DutySession(expenseMap(response['data']));
      if (returned.id == stopped?.id) stopped = returned;
      if (session?.id == returned.id) {
        if (session!.isOn && returned.needsActualKm) stopped = returned;
        session = returned;
        await _persist();
        if (!returned.isOn) await _stopTracking();
        update();
      }
      if (!returned.isOn) await _refreshCash();
    }
    // The km form is offered only after every remaining batch has finished.
    if (stopped != null && _owner == owner) {
      unawaited(enterActualKm(stopped));
    }
    if (missingError != null) throw missingError;
  }

  Future<DutySession?> enterActualKm(DutySession duty) async {
    if (!duty.needsActualKm || _actualKmOpen || Get.context == null) {
      return null;
    }
    _actualKmOpen = true;
    try {
      return await Get.dialog<DutySession>(
        DutyActualKmDialog(
          duty: duty,
          submit: (km) => submitActualKm(duty, km),
        ),
        barrierDismissible: false,
      );
    } finally {
      _actualKmOpen = false;
    }
  }

  Future<DutySession> submitActualKm(DutySession duty, num km) async {
    if (!km.isFinite || km < 0) {
      throw ExpenseApiException(
        422,
        'Enter a valid, non-negative number of km.',
      );
    }
    if (busy || refreshing) {
      throw ExpenseApiException(
        409,
        'Duty is syncing. Please try again shortly.',
      );
    }
    final owner = _owner;
    if (owner.isEmpty) {
      throw ExpenseApiException(401, 'Please log in again.');
    }
    busy = true;
    bool recover = false;
    update();
    try {
      try {
        await sync();
      } on ExpenseApiException catch (e) {
        if (e.statusCode != 404) rethrow;
        // An unrelated missing duty must not block this duty's finalisation.
        if (pendingStop?['session_id'] == duty.id ||
            (await store.batch(owner, session: duty.id)).isNotEmpty) {
          rethrow;
        }
      }
      if (_owner != owner) {
        throw ExpenseApiException(401, 'Please log in again.');
      }
      final response = await request(
        'actual-km',
        data: {'session_id': duty.id, 'actual_km': km},
      );
      final accepted = DutySession(expenseMap(response['data']));
      if (_owner != owner) {
        throw ExpenseApiException(401, 'Please log in again.');
      }
      if (session?.id == accepted.id) {
        session = accepted;
        await _persist();
      }
      await _refreshCash();
      return accepted;
    } on ExpenseApiException catch (e) {
      recover = e.statusCode == 404;
      rethrow;
    } finally {
      busy = false;
      update();
      if (recover) await reconcile();
    }
  }

  Future<void> _refreshCash() async {
    try {
      await Get.find<ExpenseController>().loadLedger();
    } catch (_) {
      warning = 'Duty saved. Refresh My cash to load the latest balance.';
    }
  }

  Future<void> suspend() async {
    await _stopTracking();
    _owner = '';
    session = null;
    pendingStop = null;
    ready = false;
    _retryAt = null;
    error = '';
    update();
  }

  @override
  void onClose() {
    WidgetsBinding.instance.removeObserver(this);
    _uploadTimer?.cancel();
    unawaited(_connectivity?.cancel());
    unawaited(_stopTracking());
    super.onClose();
  }
}
