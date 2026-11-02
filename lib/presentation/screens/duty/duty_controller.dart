import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart' hide ServiceStatus;

import '../../../data/api_services.dart';
import '../../../data/duty_store.dart';
import '../../../data/duty_requests.dart';
import '../../../domain/Model/duty.dart';
import '../../../domain/Model/expense/expense_v1.dart';
import '../../controllers/user_controller.dart';
import '../expense_management/expense_controller.dart';
import '../expense_management/components/expense_dialog.dart';
import 'duty_actual_km.dart';

class DutyController extends GetxController with WidgetsBindingObserver {
  final ApiService api;
  final DutyStore store;
  DutyController({ApiService? api, DutyStore? store})
    : api = api ?? ApiService(),
      store = store ?? DutyStore();
  DutySession? session;
  Map<String, dynamic>? pendingStop;
  bool busy = false, ready = false, refreshing = false;
  int _intentRevision = 0;
  String error = '', warning = '';
  DateTime? _retryAt;
  String _owner = '';
  Timer? _uploadTimer;
  StreamSubscription<Position>? _positions;
  StreamSubscription<ServiceStatus>? _services;
  Position? _last;
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
      final response = expenseMap(
        (await api.expenseRequest(
          'v1/duty/$suffix',
          method: data == null ? 'GET' : 'POST',
          data: data,
          query: query,
        )).data,
      );
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
        if (previous?.isOn == true) {
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
      await _stopTracking();
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
    final LocationSettings settings =
        defaultTargetPlatform == TargetPlatform.android
        ? AndroidSettings(
            accuracy: LocationAccuracy.high,
            distanceFilter: 0,
            intervalDuration: const Duration(seconds: 10),
            foregroundNotificationConfig: const ForegroundNotificationConfig(
              notificationTitle: 'T2P duty',
              notificationIcon: AndroidResource(name: 'ic_duty_notification'),
              color: Color(0xFFB42332),
              setOngoing: true,
              notificationText: 'You are on duty. Location tracking is active.',
              enableWakeLock: true,
            ),
          )
        : AppleSettings(
            accuracy: LocationAccuracy.best,
            distanceFilter: 0,
            pauseLocationUpdatesAutomatically: false,
            showBackgroundLocationIndicator: true,
            allowBackgroundLocationUpdates: true,
          );
    _positions = Geolocator.getPositionStream(locationSettings: settings).listen(
      (position) {
        if (!on) return;
        final previous = _last;
        if (previous != null &&
            position.timestamp.difference(previous.timestamp).inSeconds < 30 &&
            Geolocator.distanceBetween(
                  previous.latitude,
                  previous.longitude,
                  position.latitude,
                  position.longitude,
                ) <
                50) {
          return;
        }
        _last = position;
        final owner = _owner, id = session!.id;
        _writes = _writes
            .then(
              (_) => store.add(owner, id, {
                'lat': position.latitude,
                'lng': position.longitude,
                'at': position.timestamp.toUtc().toIso8601String(),
                'accuracy': position.accuracy,
              }),
            )
            .catchError((Object e) {
              warning = 'Unable to save GPS point: $e';
              update();
            });
        if (warning.isNotEmpty) {
          warning = '';
          update();
        }
      },
      onError: (Object e) {
        warning =
            'Location tracking interrupted. Check GPS and location permissions. $e';
        unawaited(_positions?.cancel());
        _positions = null;
        update();
      },
    );
    _services ??= Geolocator.getServiceStatusStream().listen((status) {
      warning = status == ServiceStatus.disabled
          ? 'GPS is off. Enable it to record your full route.'
          : '';
      update();
    });
  }

  Future<void> _stopTracking() async {
    await _positions?.cancel();
    _positions = null;
    await _services?.cancel();
    _services = null;
    await _writes;
    _last = null;
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
      final rows = await store.batch(owner, session: '${stop['session_id']}');
      final response = await request(
        'off',
        data: {...stop, 'points': rows.map(DutyStore.point).toList()},
      );
      if (_owner != owner) return;
      await store.acknowledge(rows);
      session = DutySession(expenseMap(response['data']));
      pendingStop = null;
      await _persist();
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
    unawaited(_stopTracking());
    super.onClose();
  }
}
