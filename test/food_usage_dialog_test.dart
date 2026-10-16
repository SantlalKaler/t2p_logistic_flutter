import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:t2p_logistic/presentation/screens/expense_management/components/food_usage_dialog.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() async {
    if (const bool.fromEnvironment('EXPENSE_CAPTURE')) {
      final fonts = FontLoader('Roboto');
      for (final name in ['regular', 'medium', 'bold']) {
        fonts.addFont(
          File(
            '.fvm/flutter_sdk/bin/cache/artifacts/material_fonts/roboto-$name.ttf',
          ).readAsBytes().then(ByteData.sublistView),
        );
      }
      await fonts.load();
      final icons = FontLoader('MaterialIcons')
        ..addFont(
          File(
            '.fvm/flutter_sdk/bin/cache/artifacts/material_fonts/materialicons-regular.otf',
          ).readAsBytes().then(ByteData.sublistView),
        );
      await icons.load();
    }
  });
  final capture = GlobalKey();
  Future<void> open(
    WidgetTester tester,
    Size size, {
    ValueChanged<Map<String, dynamic>?>? result,
    double scale = 1,
  }) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = size;
    await tester.binding.setSurfaceSize(size);
    await tester.pumpWidget(
      MaterialApp(
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(context)
              .copyWith(textScaler: TextScaler.linear(scale)),
          child: child!,
        ),
        home: Scaffold(
          body: Builder(
            builder: (context) => Center(
              child: TextButton(
                onPressed: () async {
                  final value = await showDialog<Map<String, dynamic>>(
                    context: context,
                    builder: (context) => RepaintBoundary(
                      key: capture,
                      child: const FoodUsageDialog(
                        available: 3,
                        backdateDays: 7,
                        productName: 'Nolen Gur Sankha (Pack of 12) - Nalin Chandra Das & Sons, Kolkata',
                      ),
                    ),
                  );
                  result?.call(value);
                },
                child: const Text('Open'),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();
  }

  Future<void> close(WidgetTester tester) async {
    await tester.pumpWidget(const SizedBox.shrink());
    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
    tester.view.resetViewInsets();
    await tester.binding.setSurfaceSize(null);
  }

  for (final scenario in [
    (size: const Size(320, 568), keyboard: 280.0, scale: 1.0),
    (size: const Size(390, 844), keyboard: 300.0, scale: 1.3),
    (size: const Size(640, 360), keyboard: 0.0, scale: 1.0),
  ]) {
    testWidgets(
      'food usage stays within ${scenario.size} with keyboard ${scenario.keyboard}',
      (tester) async {
        await open(tester, scenario.size, scale: scenario.scale);
        expect(tester.takeException(), isNull);
        if (scenario.size.width == 320 &&
            const bool.fromEnvironment('EXPENSE_CAPTURE')) {
          final boundary =
              capture.currentContext!.findRenderObject()!
                  as RenderRepaintBoundary;
          await tester.runAsync(() async {
            final image = await boundary.toImage();
            final bytes = await image.toByteData(
              format: ui.ImageByteFormat.png,
            );
            await Directory('.codex/tmp').create(recursive: true);
            await File('.codex/tmp/food-usage-dialog.png')
                .writeAsBytes(bytes!.buffer.asUint8List());
          });
        }
        tester.view.viewInsets = FakeViewPadding(bottom: scenario.keyboard);
        await tester.pumpAndSettle();
        expect(find.text('Cancel').hitTestable(), findsOneWidget);
        expect(
          find.byKey(const ValueKey('food-usage-save')).hitTestable(),
          findsOneWidget,
        );
        expect(
          tester
              .getBottomRight(find.byKey(const ValueKey('food-usage-save')))
              .dy,
          lessThanOrEqualTo(scenario.size.height - scenario.keyboard),
        );
        await tester.drag(
          find.byKey(const ValueKey('food-usage-scroll')),
          const Offset(0, -400),
        );
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        await close(tester);
      },
    );
  }
  testWidgets(
    'quantity and consumed validation preserve the food usage payload',
    (tester) async {
      Map<String, dynamic>? saved;
      await open(
        tester,
        const Size(390, 844),
        result: (value) => saved = value,
      );
      await tester.enterText(
        find.byKey(const ValueKey('food-usage-quantity')),
        '4',
      );
      await tester.tap(find.byKey(const ValueKey('food-usage-save')));
      await tester.pumpAndSettle();
      expect(find.text('Cannot exceed 3'), findsOneWidget);
      expect(saved, isNull);
      await tester.tap(find.text('Adjusted on another order'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Consumed').last);
      await tester.pumpAndSettle();
      await tester.enterText(
        find.byKey(const ValueKey('food-usage-quantity')),
        '2',
      );
      await tester.tap(find.byKey(const ValueKey('food-usage-save')));
      await tester.pumpAndSettle();
      expect(find.text('Enter who consumed the food'), findsOneWidget);
      await tester.enterText(
        find.byKey(const ValueKey('food-usage-note')),
        'Office staff',
      );
      await tester.tap(find.byKey(const ValueKey('food-usage-save')));
      await tester.pumpAndSettle();
      expect(saved?['type'], 'consumed');
      expect(saved?['quantity'], '2');
      expect(saved?['note'], 'Office staff');
      expect(saved!.containsKey('orderid'), false);
      expect(tester.takeException(), isNull);
      await close(tester);
    },
  );
}
