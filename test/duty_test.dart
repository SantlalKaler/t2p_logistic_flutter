import 'package:flutter/material.dart';
import 'package:t2p_logistic/presentation/screens/expense_management/expense_ledger.dart';

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart' hide Response;
import 'package:get_storage/get_storage.dart';
import 'package:t2p_logistic/data/api_services.dart';
import 'package:t2p_logistic/data/duty_store.dart';
import 'package:t2p_logistic/domain/Model/duty.dart';
import 'package:t2p_logistic/domain/Model/expense/expense_v1.dart';
import 'package:t2p_logistic/presentation/controllers/user_controller.dart';
import 'package:t2p_logistic/presentation/screens/duty/duty_controller.dart';
import 'package:t2p_logistic/presentation/screens/expense_management/expense_controller.dart';

class TestUser extends UserController {
  @override
  String get userId => 'user-a';
  @override
  bool get isLoggedIn => true;
}

class MemoryStore extends DutyStore {
  Map<String, dynamic> state = {};
  final rows = <Map<String, Object?>>[];
  @override
  Future<Map<String, dynamic>> read(String owner) async => Map.from(state);
  @override
  Future<void> write(String owner, Map<String, dynamic> value) async {
    state = Map.from(value);
  }

  @override
  Future<List<Map<String, Object?>>> batch(
    String owner, {
    String? session,
  }) async => rows
      .where(
        (r) =>
            r['owner'] == owner && (session == null || r['session'] == session),
      )
      .take(500)
      .toList();
  @override
  Future<void> acknowledge(List<Map<String, Object?>> sent) async =>
      rows.removeWhere((r) => sent.any((s) => s['id'] == r['id']));
  void seed(int count) {
    for (var i = 0; i < count; i++) {
      rows.add({
        'id': i,
        'owner': 'user-a',
        'session': 's1',
        'body': jsonEncode({
          'lat': 25,
          'lng': 85,
          'at':
              '2026-11-01T01:${(i ~/ 60).toString().padLeft(2, '0')}:${(i % 60).toString().padLeft(2, '0')}.000Z',
        }),
      });
    }
  }
}

class FakeApi extends ApiService {
  bool fail = false;
  Completer<void>? holdMe;
  final calls = <String>[];
  final bodies = <Map<String, dynamic>>[];
  @override
  Future<Response<dynamic>> expenseRequest(
    String path, {
    String method = 'GET',
    dynamic data,
    Map<String, dynamic>? query,
    ResponseType? responseType,
    Duration? timeout,
  }) async {
    calls.add(path);
    if (path.endsWith('/me') && holdMe != null) await holdMe!.future;
    if (data is Map<String, dynamic>) bodies.add(Map.from(data));
    if (fail) throw ExpenseApiException(null, 'Offline');
    return Response(
      requestOptions: RequestOptions(path: path),
      statusCode: 200,
      data: {
        'status': 'success',
        'data': path.endsWith('/me')
            ? null
            : {
                'session_id': 's1',
                'status': 'off',
                'order': {'_id': 'order-a', 'orderid': 'T2P-A'},
                'distance_km': 2,
                'rate_per_km': 5,
                'amount': 10,
              },
      },
    );
  }
}

class FakeCash extends ExpenseController {
  int refreshes = 0;
  @override
  Future<void> loadLedger({
    int nextPage = 1,
    String from = '',
    String to = '',
    String type = '',
  }) async {
    refreshes++;
  }
}

class TestDuty extends DutyController {
  TestDuty(FakeApi api, MemoryStore store) : super(api: api, store: store);
  @override
  bool get supported => true;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() async {
    final dir = await Directory.systemTemp.createTemp('t2p_duty_tests_');
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          const MethodChannel('plugins.flutter.io/path_provider'),
          (_) async => dir.path,
        );
    await GetStorage.init();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          const MethodChannel('flutter.baseflow.com/geolocator'),
          (call) async =>
              call.method == 'isLocationServiceEnabled' ? false : null,
        );
  });
  setUp(() {
    Get.testMode = true;
    Get.put<UserController>(TestUser());
    Get.put<ExpenseController>(FakeCash());
  });
  tearDown(() => Get.reset());
  test('duty uses server amounts, nullable order and terminal statuses', () {
    final duty = DutySession({
      'session_id': 's1',
      'status': 'on',
      'order': {'_id': 'a', 'orderid': 'T2P-A'},
      'distance_km': 99,
      'rate_per_km': 5,
      'amount': 17.25,
    });
    expect(duty.matches('a'), isTrue);
    expect(duty.matches('T2P-A'), isTrue);
    expect(duty.matches('b'), isFalse);
    expect(duty.amount, 17.25);
    expect(DutySession({'order': null}).isTotal, isTrue);
    for (final status in [
      'DELIVERED',
      'DELIVERED_TO_CUSTOMER',
      'cancelled',
      'FAILED',
    ]) {
      expect(dutyOrderClosed(status), isTrue);
    }
    expect(dutyOrderClosed('DELIVERED_TO_CARGO_PARTNER'), isFalse);
  });
  test(
    'offline Stop retains original time and points; retry sends Stop first',
    () async {
      final api = FakeApi()..fail = true;
      final store = MemoryStore()
        ..state = {
          'session': {'session_id': 's1', 'status': 'on', 'order': null},
          'stop': {'session_id': 's1', 'at': '2026-11-01T02:00:00Z'},
        };
      store.seed(501);
      final c = TestDuty(api, store);
      await c.reconcile();
      expect(c.on, isFalse);
      expect(c.pendingStop, isNotNull);
      expect(store.rows.length, 501);
      api.fail = false;
      api.calls.clear();
      api.bodies.clear();
      await c.reconcile();
      expect(api.calls, ['v1/duty/off', 'v1/duty/points', 'v1/duty/me']);
      expect(api.bodies.first['at'], '2026-11-01T02:00:00Z');
      expect((api.bodies.first['points'] as List).length, 500);
      expect(store.rows, isEmpty);
      expect(c.pendingStop, isNull);
      expect((Get.find<ExpenseController>() as FakeCash).refreshes, 2);
    },
  );
  test(
    'failed point upload keeps all points and retry batches at 500',
    () async {
      final api = FakeApi()..fail = true;
      final store = MemoryStore()..seed(1001);
      final c = TestDuty(api, store);
      await c.reconcile();
      expect(store.rows.length, 1001);
      api.fail = false;
      api.calls.clear();
      api.bodies.clear();
      await c.reconcile();
      expect(api.bodies.map((b) => (b['points'] as List).length), [
        500,
        500,
        1,
      ]);
      expect(store.rows, isEmpty);
    },
  );
  test(
    'delivery of another order or during total duty never stops duty',
    () async {
      final api = FakeApi();
      final c = TestDuty(api, MemoryStore());
      c.session = DutySession({
        'session_id': 's1',
        'status': 'on',
        'order': null,
      });
      await c.delivered('order-a');
      c.session = DutySession({
        'session_id': 's1',
        'status': 'on',
        'order': {'_id': 'order-b'},
      });
      await c.delivered('order-a');
      expect(api.calls, isEmpty);
      expect(c.on, isTrue);
    },
  );
  test('only the matching order stops; GPS is optional at Stop', () async {
    final api = FakeApi();
    final c = TestDuty(api, MemoryStore());
    await c.reconcile();
    c.session = DutySession({
      'session_id': 's1',
      'status': 'on',
      'order': {'_id': 'order-a'},
    });
    await c.delivered('order-a');
    expect(api.calls.last, 'v1/duty/off');
    expect(c.on, isFalse);
    expect(api.bodies.last['session_id'], 's1');
    expect(api.bodies.last['at'], isNotEmpty);
    await c.stop();
    expect(api.calls.where((p) => p.endsWith('/off')).length, 1);
  });
  test(
    'Stop is available during refresh and a stale response cannot undo it',
    () async {
      final api = FakeApi();
      final c = TestDuty(api, MemoryStore());
      await c.reconcile();
      c.session = DutySession({
        'session_id': 's1',
        'status': 'on',
        'order': null,
      });
      api.calls.clear();
      api.holdMe = Completer<void>();
      final refreshing = c.reconcile();
      while (!api.calls.contains('v1/duty/me')) {
        await Future<void>.delayed(Duration.zero);
      }
      expect(c.busy, isFalse);
      expect(c.refreshing, isTrue);
      await c.stop();
      expect(c.on, isFalse);
      expect(c.session!.id, 's1');
      api.holdMe!.complete();
      await refreshing;
      expect(c.session!.id, 's1');
      expect(c.session!.isOn, isFalse);
    },
  );
  testWidgets(
    'negative cash has a leading minus and duty rows cannot open expenses',
    (tester) async {
      Get.find<ExpenseController>().ledger = {
        'account': {'balance': -50000},
        'summary': {'duty_deducted': 10000},
        'entries': [
          {
            'type': 'DUTY_DEBIT',
            'type_label': 'Duty (km x rate)',
            'direction': 'debit',
            'amount': 10000,
            'expense': 'should-not-open',
            'reference': 'T2P-A',
            'note': 'Duty 10 km x Rs 10',
          },
        ],
      };
      await tester.pumpWidget(
        GetMaterialApp(home: const ExpenseLedgerScreen()),
      );
      await tester.pumpAndSettle();
      expect(find.text('-\u20b9500.00'), findsOneWidget);
      final duty = find.text('Duty (km x rate)');
      await tester.scrollUntilVisible(
        duty,
        250,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pumpAndSettle();
      await tester.tap(duty);
      await tester.pumpAndSettle();
      expect(find.byType(ExpenseLedgerScreen), findsOneWidget);
      expect(find.text('Duty 10 km x Rs 10'), findsOneWidget);
    },
  );
}
