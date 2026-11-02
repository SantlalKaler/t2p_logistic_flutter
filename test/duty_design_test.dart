import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:t2p_logistic/domain/Model/duty.dart';
import 'package:t2p_logistic/presentation/controllers/user_controller.dart';
import 'package:t2p_logistic/presentation/screens/duty/duty_controller.dart';
import 'package:t2p_logistic/presentation/screens/duty/duty_widgets.dart';
import 'package:t2p_logistic/presentation/screens/duty/duty_history.dart';

import 'duty_test.dart' as fixtures;

class DesignUser extends fixtures.TestUser {
  @override
  String get userType => 'delivery_boy';
}

final sampleDuty = {
  'session_id': 's1',
  'status': 'off',
  'order': {'_id': 'order-a', 'orderid': 'T2P-1790000101'},
  'started_at': '2026-11-01T04:30:00Z',
  'ended_at': '2026-11-01T09:30:00Z',
  'start_address': 'Boring Road, Patna',
  'end_address': 'Kankarbagh, Patna',
  'distance_km': 12.34,
  'duration_seconds': 18000,
  'rate_per_km': 5,
  'amount': 61.7,
};

class DesignDuty extends fixtures.TestDuty {
  Map<String, dynamic>? lastQuery;
  DesignDuty() : super(fixtures.FakeApi(), fixtures.MemoryStore());
  @override
  Future<Map<String, dynamic>> request(
    String suffix, {
    dynamic data,
    Map<String, dynamic>? query,
  }) async {
    lastQuery = query;
    return {
      'data': [sampleDuty],
      'totals': {'duties': 1, 'distance_km': 12.34, 'amount': 61.7},
      'pagination': {'pages': 1},
    };
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() async {
    final dir = await Directory.systemTemp.createTemp('t2p_duty_design_');
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          const MethodChannel('plugins.flutter.io/path_provider'),
          (_) async => dir.path,
        );
    await GetStorage.init();
    if (const bool.fromEnvironment('DUTY_CAPTURE')) {
      final fonts =
          '${Platform.environment['FLUTTER_ROOT'] ?? '.fvm/flutter_sdk'}/bin/cache/artifacts/material_fonts';
      for (final entry in {
        'Roboto': 'roboto-regular.ttf',
        'MaterialIcons': 'materialicons-regular.otf',
      }.entries) {
        final loader = FontLoader(entry.key)
          ..addFont(
            Future.value(
              ByteData.sublistView(
                await File('$fonts/${entry.value}').readAsBytes(),
              ),
            ),
          );
        await loader.load();
      }
    }
  });
  setUp(() {
    Get.testMode = true;
    Get.put<UserController>(DesignUser());
  });
  tearDown(() => Get.reset());

  Future<void> capture(WidgetTester tester, String name) async {
    if (!const bool.fromEnvironment('DUTY_CAPTURE')) return;
    await tester.runAsync(() async {
      final boundary = tester.firstRenderObject<RenderRepaintBoundary>(
        find.byType(RepaintBoundary).first,
      );
      final image = await boundary.toImage(pixelRatio: 2);
      final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
      final dir = Directory('tmp/duty-design')..createSync(recursive: true);
      File('${dir.path}/$name.png')
          .writeAsBytesSync(bytes!.buffer.asUint8List());
      image.dispose();
    });
  }

  for (final width in [320.0, 390.0]) {
    testWidgets('active duty panel fits width $width and preserves state', (
      tester,
    ) async {
      await tester.binding.setSurfaceSize(Size(width, 844));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      final c = DesignDuty()
        ..ready = true
        ..session = DutySession({...sampleDuty, 'status': 'on'});
      Get.put<DutyController>(c);
      await tester.pumpWidget(
        GetMaterialApp(
          home: Scaffold(
            body: RepaintBoundary(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: const [DutyPanel()],
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('On duty'), findsOneWidget);
      expect(find.text('12.34 km'), findsOneWidget);
      expect(find.text('₹61.70'), findsOneWidget);
      expect(tester.widget<Switch>(find.byType(Switch)).value, isTrue);
      expect(tester.takeException(), isNull);
      if (width == 390) await capture(tester, 'active-duty');
      await tester.pumpWidget(const SizedBox.shrink());
      await Get.delete<DutyController>(force: true);
    });

    testWidgets('history fits width $width and filters clear correctly', (
      tester,
    ) async {
      await tester.binding.setSurfaceSize(Size(width, 844));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      final c = DesignDuty();
      Get.put<DutyController>(c);
      await tester.pumpWidget(
        GetMaterialApp(home: RepaintBoundary(child: const DutyHistoryScreen())),
      );
      await tester.pumpAndSettle();
      expect(find.text('₹61.70'), findsWidgets);
      expect(find.textContaining('Boring Road, Patna'), findsOneWidget);
      expect(tester.takeException(), isNull);
      if (width == 390) await capture(tester, 'duty-history');
      await tester.tap(find.text('Filter history'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), 'T2P-123');
      await tester.scrollUntilVisible(
        find.text('Apply filters'),
        150,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pumpAndSettle();
      await tester.ensureVisible(
        find.widgetWithText(FilledButton, 'Apply filters'),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('Apply filters'));
      await tester.pumpAndSettle();
      expect(c.lastQuery?['order'], 'T2P-123');
      await tester.tap(find.text('Clear'));
      await tester.pumpAndSettle();
      expect(c.lastQuery?.containsKey('order'), isFalse);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox.shrink());
      await Get.delete<DutyController>(force: true);
    });
  }
}
