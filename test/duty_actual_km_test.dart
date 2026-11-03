import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:t2p_logistic/domain/Model/duty.dart';
import 'package:t2p_logistic/domain/Model/expense/expense_v1.dart';
import 'package:t2p_logistic/presentation/controllers/user_controller.dart';
import 'package:t2p_logistic/presentation/screens/duty/duty_actual_km.dart';
import 'package:t2p_logistic/presentation/screens/duty/duty_controller.dart';
import 'package:t2p_logistic/presentation/screens/duty/duty_history.dart';
import 'package:t2p_logistic/presentation/screens/expense_management/expense_controller.dart';

import 'duty_test.dart' as fixtures;

final pending = DutySession({
  'session_id': 's1',
  'status': 'off',
  'order': null,
  'distance_km': 10,
  'rate_per_km': 5,
  'amount': 0,
  'start_address': 'Boring Road',
  'end_address': 'Kankarbagh',
  'needs_actual_km': true,
});

class HistoryDuty extends fixtures.TestDuty {
  HistoryDuty() : super(fixtures.FakeApi(), fixtures.MemoryStore());
  @override
  Future<Map<String, dynamic>> request(
    String suffix, {
    dynamic data,
    Map<String, dynamic>? query,
  }) async => {
    'data': [pending.json],
    'totals': {
      'duties': 1,
      'distance_km': 10,
      'actual_km': 0,
      'awaiting_actual_km': 1,
    },
    'pagination': {'pages': 1},
  };
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() async {
    final dir = await Directory.systemTemp.createTemp('duty_actual_km_tests');
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          const MethodChannel('plugins.flutter.io/path_provider'),
          (_) async => dir.path,
        );
    await GetStorage.init();
  });
  setUp(() {
    Get.testMode = true;
    Get.put<UserController>(fixtures.TestUser());
    Get.put<ExpenseController>(fixtures.FakeCash());
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          const MethodChannel('flutter.baseflow.com/geolocator'),
          (call) async =>
              call.method == 'isLocationServiceEnabled' ? false : null,
        );
  });
  tearDown(() {
    Get.reset();
  });

  Future<void> openForm(
    WidgetTester tester,
    Future<DutySession> Function(num) submit,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => TextButton(
              onPressed: () => showDialog<DutySession>(
                context: context,
                builder: (_) =>
                    DutyActualKmDialog(duty: pending, submit: submit),
              ),
              child: const Text('Open'),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();
  }

  testWidgets(
    'km form previews totals, keeps server errors and shows accepted amount',
    (tester) async {
      var attempts = 0;
      await openForm(tester, (km) async {
        attempts++;
        if (attempts == 1) {
          throw ExpenseApiException(
            422,
            'Invalid input',
            fields: {'actual_km': 'Your difference limit is 1 km.'},
          );
        }
        return DutySession({
          ...pending.json,
          'actual_km': km,
          'difference_km': 2,
          'needs_actual_km': false,
          'amount': 59.99,
        });
      });
      await tester.enterText(find.byType(TextField), '12');
      await tester.pump();
      expect(find.text('Difference: 2.00 km'), findsOneWidget);
      expect(find.text('Estimated total payable: ₹60.00'), findsOneWidget);
      await tester.tap(find.text('Submit km'));
      await tester.pumpAndSettle();
      expect(find.text('Your difference limit is 1 km.'), findsOneWidget);
      expect(find.byType(TextField), findsOneWidget);
      await tester.tap(find.text('Submit km'));
      await tester.pumpAndSettle();
      expect(find.text('Duty amount accepted'), findsOneWidget);
      expect(find.text('₹59.99'), findsOneWidget);
      expect(find.text('Actual km: 12.00 km'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('invalid numbers stay local and conflict leaves form open', (
    tester,
  ) async {
    var calls = 0;
    await openForm(tester, (_) async {
      calls++;
      throw ExpenseApiException(409, 'A different value was already saved.');
    });
    for (final value in ['', '-1', 'NaN', 'Infinity']) {
      await tester.enterText(find.byType(TextField), value);
      await tester.tap(find.text('Submit km'));
      await tester.pumpAndSettle();
    }
    expect(calls, 0);
    await tester.enterText(find.byType(TextField), '0');
    await tester.tap(find.text('Submit km'));
    await tester.pumpAndSettle();
    expect(calls, 1);
    expect(find.text('A different value was already saved.'), findsOneWidget);
    expect(find.byType(TextField), findsOneWidget);
  });

  testWidgets('history offers pending km entry and shows pending totals', (
    tester,
  ) async {
    Get.put<DutyController>(HistoryDuty());
    await tester.pumpWidget(GetMaterialApp(home: const DutyHistoryScreen()));
    await tester.pumpAndSettle();
    expect(find.text('Awaiting actual km: 1'), findsOneWidget);
    await tester.scrollUntilVisible(find.text('Enter km'), 200);
    await tester.pumpAndSettle();
    expect(find.text('Pending actual km · Unpaid'), findsOneWidget);
    await tester.tap(find.text('Enter km'));
    await tester.pumpAndSettle();
    expect(find.text('Enter actual km'), findsOneWidget);
    await tester.tap(find.text('Later'));
    await tester.pumpAndSettle();
    expect(find.byType(DutyHistoryScreen), findsOneWidget);
    await tester.pumpWidget(const SizedBox.shrink());
    await Get.delete<DutyController>(force: true);
  });

  for (final confirm in [false, true]) {
    testWidgets(
      'start looks up address once and ${confirm ? 'starts after confirmation' : 'cancels without starting'}',
      (tester) async {
        final previousPlatform = debugDefaultTargetPlatformOverride;
        debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
        var gpsChecks = 0;
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(
              const MethodChannel('flutter.baseflow.com/geolocator'),
              (call) async {
                switch (call.method) {
                  case 'isLocationServiceEnabled':
                    return ++gpsChecks == 1;
                  case 'checkPermission':
                    return 3;
                  case 'getCurrentPosition':
                    return {
                      'latitude': 25.6123,
                      'longitude': 85.1234,
                      'timestamp': DateTime.now().millisecondsSinceEpoch,
                      'accuracy': 8.0,
                      'altitude': 0.0,
                      'heading': 0.0,
                      'speed': 0.0,
                      'speed_accuracy': 0.0,
                    };
                }
                return null;
              },
            );
        final api = fixtures.FakeApi();
        api.responses['v1/duty/address'] = {
          'address': confirm ? 'Boring Road, Patna' : null,
        };
        api.responses['v1/duty/on'] = {
          'session_id': 'new',
          'status': 'on',
          'order': null,
        };
        final c = fixtures.TestDuty(api, fixtures.MemoryStore());
        await c.reconcile();
        await tester.pumpWidget(
          GetMaterialApp(
            home: Scaffold(
              body: TextButton(onPressed: c.start, child: const Text('Start')),
            ),
          ),
        );
        await tester.tap(find.text('Start'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Continue'));
        await tester.pumpAndSettle();
        expect(find.text('Confirm duty start'), findsOneWidget);
        expect(api.calls.where((p) => p.endsWith('/address')).length, 1);
        expect(api.calls, isNot(contains('v1/duty/on')));
        expect(
          find.textContaining(
            confirm ? 'Boring Road, Patna' : 'Address unavailable',
          ),
          findsOneWidget,
        );
        await tester.tap(find.text(confirm ? 'Confirm' : 'Cancel'));
        await tester.pumpAndSettle();
        expect(api.calls.contains('v1/duty/on'), confirm);
        if (confirm) expect(api.bodies.last['accuracy'], 8.0);
        expect(c.on, confirm);
        await c.suspend();
        debugDefaultTargetPlatformOverride = previousPlatform;
      },
    );
  }

  testWidgets('server auto-close offers km entry on reconciliation', (
    tester,
  ) async {
    final api = fixtures.FakeApi();
    api.responses['v1/duty/history'] = [pending.json];
    final store = fixtures.MemoryStore()
      ..state = {
        'session': {...pending.json, 'status': 'on'},
      };
    final c = fixtures.TestDuty(api, store);
    await tester.pumpWidget(GetMaterialApp(home: const Scaffold()));
    await c.reconcile();
    await tester.pumpAndSettle();
    expect(c.on, isFalse);
    expect(find.text('Enter actual km'), findsOneWidget);
    await tester.tap(find.text('Later'));
    await tester.pumpAndSettle();
  });

  testWidgets('Delivered flushes remaining points before offering actual km', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(320, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final api = fixtures.FakeApi();
    api.responses['v1/duty/off'] = {...pending.json, 'distance_km': 11};
    api.responses['v1/duty/points'] = {...pending.json, 'distance_km': 11};
    final store = fixtures.MemoryStore();
    final c = fixtures.TestDuty(api, store);
    await c.reconcile();
    c.session = DutySession({
      ...pending.json,
      'status': 'on',
      'order': {'_id': 'order-a'},
    });
    store.seed(501);
    api.calls.clear();
    await tester.pumpWidget(GetMaterialApp(home: const Scaffold()));
    await c.delivered('order-a');
    await tester.pumpAndSettle();
    expect(api.calls, ['v1/duty/points', 'v1/duty/off']);
    expect(store.rows, isEmpty);
    expect(find.text('Travelled km (system): 11.00 km'), findsOneWidget);
    expect(find.text('Enter actual km'), findsOneWidget);
    expect(tester.takeException(), isNull);
    await tester.tap(find.text('Later'));
    await tester.pumpAndSettle();
  });
}
