import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:t2p_logistic/domain/Model/expense/expense_v1.dart';
import 'package:t2p_logistic/presentation/screens/expense_management/add_edit_expense_screen.dart';
import 'package:t2p_logistic/presentation/screens/expense_management/expense_controller.dart';
import 'package:t2p_logistic/presentation/screens/expense_management/components/expense_order_dropdown.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() async {
    final dir = await Directory.systemTemp.createTemp('t2p_expense_form_test_');
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          const MethodChannel('plugins.flutter.io/path_provider'),
          (_) async => dir.path,
        );
    await GetStorage.init();
    if (const bool.fromEnvironment('EXPENSE_CAPTURE')) {
      final loader = FontLoader('Roboto');
      for (final name in ['regular', 'medium', 'bold']) {
        final file = File(
          '.fvm/flutter_sdk/bin/cache/artifacts/material_fonts/roboto-$name.ttf',
        );
        if (file.existsSync()) {
          loader.addFont(
            file.readAsBytes().then((bytes) => ByteData.sublistView(bytes)),
          );
        }
      }
      await loader.load();
      final icons = File(
        '.fvm/flutter_sdk/bin/cache/artifacts/material_fonts/materialicons-regular.otf',
      );
      if (icons.existsSync()) {
        final iconLoader = FontLoader('MaterialIcons')
          ..addFont(
            icons.readAsBytes().then((bytes) => ByteData.sublistView(bytes)),
          );
        await iconLoader.load();
      }
    }
  });
  setUp(() {
    Get.testMode = true;
    final c = Get.put(ExpenseController());
    c.meta = {
      'expense_heads': [
        {'_id': 'head-1', 'name': 'Packaging material'},
      ],
      'travel_modes': [
        {'value': 'taxi', 'label': 'Taxi'},
        {'value': 'other', 'label': 'Other'},
      ],
      'categories': [
        {'code': 'PETROL', 'label': 'Petrol Filling'},
      ],
      'backdate_days': 7,
    };
  });
  tearDown(() {
    Get.reset();
  });
  Future<void> open(
    WidgetTester tester,
    String category,
    Map<String, dynamic> details, {
    GlobalKey? capture,
  }) async {
    tester.view.reset();
    await tester.binding.setSurfaceSize(const Size(390, 844));
    final screen = AddEditExpenseScreen(
      expense: ExpenseDetail.fromJson({
        'expense': {
          '_id': 'fixture-id',
          'category': category,
          'business_date': expenseToday(),
          'status': 'draft',
          'details': details,
          'version': 2,
        },
        'actions': {'edit': true},
      }),
    );
    await tester.pumpWidget(
      GetMaterialApp(
        home: RepaintBoundary(key: capture, child: screen),
      ),
    );
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  }

  testWidgets('petrol edit converts paise to rupees and preserves odometer', (
    tester,
  ) async {
    final capture = GlobalKey();
    await open(tester, 'PETROL', {
      'rate_per_litre': 10477,
      'litres': 3.25,
      'start_km': 15230,
    }, capture: capture);
    expect(find.text('104.77'), findsOneWidget);
    expect(find.text('15230'), findsOneWidget);
    expect(find.text('10477'), findsNothing);
    expect(find.text('Save and submit'), findsNothing);
    if (const bool.fromEnvironment('EXPENSE_CAPTURE')) {
      final boundary =
          capture.currentContext!.findRenderObject()! as RenderRepaintBoundary;
      await tester.runAsync(() async {
        final image = await boundary.toImage();
        final data = await image.toByteData(format: ui.ImageByteFormat.png);
        await Directory('.codex/tmp').create(recursive: true);
        await File('.codex/tmp/expense-petrol-form.png')
            .writeAsBytes(data!.buffer.asUint8List());
      });
    }
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.binding.setSurfaceSize(null);
  });
  testWidgets('miscellaneous edit restores head and rupee amount', (
    tester,
  ) async {
    await open(tester, 'MISC', {
      'expense_head': {'_id': 'head-1', 'name': 'Packaging material'},
      'description': 'Packing tape',
      'reason': 'Packing Delhi boxes',
      'amount': 8500,
    });
    expect(find.text('Packaging material'), findsOneWidget);
    expect(find.text('85.00'), findsOneWidget);
    expect(find.text('Packing tape'), findsOneWidget);
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.binding.setSurfaceSize(null);
  });
  testWidgets('travel Other mode restores conditional field', (tester) async {
    await open(tester, 'TRAVEL', {
      'from_place': 'Howrah',
      'to_place': 'Sealdah',
      'travel_mode': 'other',
      'travel_mode_other': 'Ferry',
      'amount': 32000,
    });
    expect(find.text('Ferry'), findsOneWidget);
    expect(find.text('320.00'), findsOneWidget);
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.binding.setSurfaceSize(null);
  });
  testWidgets(
    'new expense save actions stay side by side while the form scrolls',
    (tester) async {
      await tester.binding.setSurfaceSize(const Size(390, 844));
      final capture = GlobalKey();
      await tester.pumpWidget(
        GetMaterialApp(
          home: RepaintBoundary(
            key: capture,
            child: const AddEditExpenseScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('Expense type'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Petrol Filling').last);
      await tester.pumpAndSettle();
      final draft = find.byKey(const ValueKey('expense-save-draft'));
      final submit = find.byKey(const ValueKey('expense-save-submit'));
      expect(draft.hitTestable(), findsOneWidget);
      expect(submit.hitTestable(), findsOneWidget);
      final draftPosition = tester.getTopLeft(draft);
      expect(tester.getTopLeft(submit).dy, draftPosition.dy);
      await tester.drag(
        find.byKey(const ValueKey('expense-form-scroll')),
        const Offset(0, -600),
      );
      await tester.pumpAndSettle();
      expect(tester.getTopLeft(draft), draftPosition);
      expect(submit.hitTestable(), findsOneWidget);
      expect(tester.takeException(), isNull);
      await tester.drag(
        find.byKey(const ValueKey('expense-form-scroll')),
        const Offset(0, 1000),
      );
      await tester.pumpAndSettle();
      if (const bool.fromEnvironment('EXPENSE_CAPTURE')) {
        final boundary =
            capture.currentContext!.findRenderObject()!
                as RenderRepaintBoundary;
        await tester.runAsync(() async {
          final image = await boundary.toImage();
          final data = await image.toByteData(format: ui.ImageByteFormat.png);
          await File('.codex/tmp/expense-new-design.png')
              .writeAsBytes(data!.buffer.asUint8List());
        });
      }
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.binding.setSurfaceSize(null);
    },
  );
  testWidgets(
    'order dropdown keeps the order list collapsed and applies multiple selections',
    (tester) async {
      await tester.binding.setSurfaceSize(const Size(390, 844));
      Set<String> selected = {};
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Padding(
              padding: const EdgeInsets.all(20),
              child: StatefulBuilder(
                builder: (context, set) => ExpenseOrderDropdown(
                  orders: const [
                    {'_id': 'one', 'orderid': 'T2P-1001'},
                    {'_id': 'two', 'orderid': 'T2P-1002'},
                  ],
                  selected: selected,
                  onSearch: (_) async {},
                  onApply: (value) => set(() => selected = value),
                ),
              ),
            ),
          ),
        ),
      );
      expect(find.text('T2P-1001'), findsNothing);
      await tester.tap(find.byKey(const ValueKey('expense-order-dropdown')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('T2P-1001'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('T2P-1002'));
      await tester.pumpAndSettle();
      expect(find.text('2/50 selected'), findsOneWidget);
      await tester.tap(find.text('Apply'));
      await tester.pumpAndSettle();
      expect(selected, {'one', 'two'});
      expect(find.text('2 orders selected'), findsOneWidget);
      expect(find.text('T2P-1001'), findsNothing);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.binding.setSurfaceSize(null);
    },
  );
}
