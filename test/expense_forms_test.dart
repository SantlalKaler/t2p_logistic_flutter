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
import 'package:t2p_logistic/presentation/screens/expense_management/expense_detail.dart';
import 'package:t2p_logistic/presentation/screens/expense_management/components/expense_order_dropdown.dart';
import 'package:t2p_logistic/presentation/screens/expense_management/components/expense_design.dart';

class RecordingExpenseController extends ExpenseController {
  Map<String, dynamic>? saved;
  List<Map<String, dynamic>> lookupOrders = [];
  String? openedId;
  @override
  Future<List<Map<String, dynamic>>> lookup(
    String name, {
    Map<String, dynamic>? query,
  }) async => lookupOrders;
  @override
  Future<Map<String, dynamic>> lookupData(
    String name, {
    Map<String, dynamic>? query,
  }) async => {'km': null, 'message': 'Not available'};
  @override
  Future<ExpenseDetail> getDetail(String id) async {
    openedId = id;
    return ExpenseDetail.fromJson({
      'expense': {
        '_id': id,
        'category': 'DELIVERY',
        'status': 'draft',
        'details': {},
      },
      'actions': {},
    });
  }

  @override
  Future<ExpenseDetail?> save(Map<String, dynamic> body, {String? id}) async {
    saved = body;
    return null;
  }
}

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
    if (const bool.fromEnvironment('EXPENSE_CAPTURE') ||
        const bool.fromEnvironment('EXPENSE_DROPDOWN_CAPTURE')) {
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
    List<Map<String, dynamic>> incomplete = const [],
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
          'incomplete': incomplete,
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

  Future<RecordingExpenseController> recordSaves() async {
    final meta = Get.find<ExpenseController>().meta;
    await Get.delete<ExpenseController>();
    final c = RecordingExpenseController()..meta = meta;
    Get.put<ExpenseController>(c);
    return c;
  }

  testWidgets('Delivery shows purchase city and date for every order', (
    tester,
  ) async {
    final c = await recordSaves();
    c.lookupOrders = [
      {
        '_id': 'order-1',
        'orderid': 'T2P-1001',
        'vendor_city': {'name': 'KOLKATA'},
        'order_city': {'name': 'DELHI'},
        'delivery_date': '2026-10-27',
        'timeslot': 'Evening',
        'sides': ['delivery'],
      },
      {
        '_id': 'order-2',
        'orderid': 'T2P-1002',
        'vendor_city': {'name': 'MUMBAI'},
        'delivery_date': '2026-10-28',
      },
    ];
    await open(tester, 'DELIVERY', {'order': 'order-1', 'side': 'delivery'});
    expect(find.text('Purchase city: KOLKATA'), findsOneWidget);
    expect(find.text('Delivery date: 2026-10-27'), findsOneWidget);
    expect(find.text('Purchase city: DELHI'), findsNothing);
    final orders = find.widgetWithText(
      DropdownButtonFormField<String>,
      'Order',
    );
    await tester.ensureVisible(orders);
    await tester.tap(orders);
    await tester.pumpAndSettle();
    expect(find.text('Purchase city: MUMBAI'), findsOneWidget);
    expect(find.text('Delivery date: 2026-10-28'), findsOneWidget);
    expect(tester.takeException(), isNull);
    await tester.tap(find.text('T2P-1002').last);
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('expense-save-draft')));
    await tester.pumpAndSettle();
    expect(c.saved?['details'], {'order': 'order-2'});
    c.lookupOrders = [];
    final search = find.widgetWithText(TextFormField, 'Find order by number');
    await tester.ensureVisible(search);
    await tester.enterText(search, 'other-order');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();
    expect(find.text('Purchase city: MUMBAI'), findsOneWidget);
    expect(find.text('Delivery date: 2026-10-28'), findsOneWidget);
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.binding.setSurfaceSize(null);
  });

  testWidgets('Purchase shows each selected order delivery city and date', (
    tester,
  ) async {
    final c = await recordSaves();
    c.lookupOrders = [
      {
        '_id': 'order-1',
        'orderid': 'T2P-1001',
        'vendor_city': {'name': 'KOLKATA'},
        'order_city': {'name': 'DELHI'},
        'delivery_date': '2026-10-27',
      },
      {'_id': 'order-2', 'orderid': 'T2P-1002'},
    ];
    await open(tester, 'FOOD_PURCHASE', {
      'orders': ['order-1', 'order-2'],
      'items': [],
    });
    expect(find.text('Delivery city: DELHI'), findsOneWidget);
    expect(find.text('Delivery date: 2026-10-27'), findsOneWidget);
    expect(find.text('Delivery city: KOLKATA'), findsNothing);
    expect(find.text('Delivery city: Not available'), findsOneWidget);
    expect(find.text('Delivery date: Not available'), findsOneWidget);
    final dropdown = find.byKey(const ValueKey('expense-order-dropdown'));
    await tester.ensureVisible(dropdown);
    await tester.tap(dropdown);
    await tester.pumpAndSettle();
    expect(find.text('Delivery city: DELHI'), findsNWidgets(2));
    expect(find.text('Delivery date: 2026-10-27'), findsNWidgets(2));
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.binding.setSurfaceSize(null);
  });

  testWidgets(
    'Expense calendar respects backdating rules and saves selected date',
    (tester) async {
      final c = await recordSaves();
      c.meta['backdate_days'] = 3;
      await open(tester, 'PETROL', {});
      final date = find.byKey(const ValueKey('expense-date:Expense date'));
      await tester.ensureVisible(date);
      await tester.tap(date);
      await tester.pumpAndSettle();
      final picker = tester.widget<CalendarDatePicker>(
        find.byType(CalendarDatePicker),
      );
      final today = DateTime.parse(expenseToday());
      final yesterday = today.subtract(const Duration(days: 1));
      expect(picker.firstDate, today.subtract(const Duration(days: 3)));
      expect(picker.lastDate, today);
      picker.onDateChanged(yesterday);
      await tester.pumpAndSettle();
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();
      expect(find.text(expenseDay(yesterday)), findsOneWidget);
      await tester.tap(find.byKey(const ValueKey('expense-save-draft')));
      await tester.pumpAndSettle();
      expect(c.saved?['expense_date'], expenseDay(yesterday));
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.binding.setSurfaceSize(null);
    },
  );

  testWidgets(
    'half-filled petrol edit saves but invalid entered numbers do not',
    (tester) async {
      final c = await recordSaves();
      await open(tester, 'PETROL', {});
      await tester.tap(find.byKey(const ValueKey('expense-save-draft')));
      await tester.pumpAndSettle();
      expect(c.saved?['details'], isEmpty);
      c.saved = null;
      final rate = find.widgetWithText(
        TextFormField,
        'Rate per litre (\u20b9)',
      );
      await tester.ensureVisible(rate);
      await tester.enterText(rate, '-5');
      await tester.tap(find.byKey(const ValueKey('expense-save-draft')));
      await tester.pumpAndSettle();
      expect(c.saved, isNull);
      expect(find.text('Enter a positive number'), findsOneWidget);
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.binding.setSurfaceSize(null);
    },
  );

  testWidgets('new petrol draft saves empty details but Submit requires them', (
    tester,
  ) async {
    final c = await recordSaves();
    await tester.binding.setSurfaceSize(const Size(390, 844));
    await tester.pumpWidget(GetMaterialApp(home: const AddEditExpenseScreen()));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Expense type'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Petrol Filling').last);
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('expense-save-draft')));
    await tester.pumpAndSettle();
    expect(c.saved?['submit'], false);
    expect(c.saved?['details'], isEmpty);
    c.saved = null;
    await tester.tap(find.byKey(const ValueKey('expense-save-submit')));
    await tester.pumpAndSettle();
    expect(c.saved, isNull);
    expect(find.text('Required'), findsWidgets);
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.binding.setSurfaceSize(null);
  });

  testWidgets(
    'incomplete Food Purchase keeps blank rate and uses fixed 5 percent GST',
    (tester) async {
      final c = await recordSaves();
      await open(tester, 'FOOD_PURCHASE', {
        'orders': ['order-1'],
        'gst_applicable': true,
        'gst_rate_bp': 1200,
        'items': [
          {
            'product': 'product-1',
            'product_name': 'Biryani',
            'rate': null,
            'order_quantity': 2,
          },
        ],
      });
      expect(find.widgetWithText(TextFormField, 'GST (%)'), findsNothing);
      await tester.tap(find.byKey(const ValueKey('expense-save-draft')));
      await tester.pumpAndSettle();
      final details = expenseMap(c.saved?['details']);
      expect(details['gst_applicable'], true);
      expect(details['gst_percent'], '5');
      expect(expenseMaps(details['items']).single.containsKey('rate'), false);
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.binding.setSurfaceSize(null);
    },
  );

  testWidgets('food GST preview updates and GST No sends zero tax choice', (
    tester,
  ) async {
    final c = await recordSaves();
    await open(tester, 'FOOD_PURCHASE', {
      'orders': ['order-1'],
      'gst_applicable': true,
      'gst_rate_bp': 500,
      'items': [
        {
          'product': 'product-1',
          'product_name': 'Biryani',
          'rate': 10000,
          'order_quantity': 2,
        },
      ],
    });
    expect(find.text('Estimated total: \u20b9210.00'), findsOneWidget);
    expect(
      find.text('Unit rate \u20b9100.00 x 2 = \u20b9200.00'),
      findsOneWidget,
    );
    final gst = find.byType(DropdownButtonFormField<bool>);
    await tester.ensureVisible(gst);
    await tester.pumpAndSettle();
    await tester.tap(gst);
    await tester.pumpAndSettle();
    await tester.tap(find.text('No').last);
    await tester.pumpAndSettle();
    expect(find.text('Estimated total: \u20b9200.00'), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('expense-save-draft')));
    await tester.pumpAndSettle();
    expect(expenseMap(c.saved?['details'])['gst_applicable'], false);
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.binding.setSurfaceSize(null);
  });

  testWidgets('Delivery opens the expense for the side the user chooses', (
    tester,
  ) async {
    final c = await recordSaves();
    c.lookupOrders = [
      {
        '_id': 'order-1',
        'orderid': 'T2P-1001',
        'side': 'delivery',
        'sides': ['pickup', 'delivery'],
        'delivery_date': expenseToday(),
        'timeslot': 'Evening',
        'expenses': [
          {'_id': 'pickup-expense', 'side': 'pickup', 'status': 'draft'},
        ],
      },
    ];
    await open(tester, 'DELIVERY', {'order': 'order-1', 'side': 'delivery'});
    expect(c.openedId, isNull);
    final side = find.widgetWithText(DropdownButtonFormField<String>, 'Side');
    await tester.ensureVisible(side);
    await tester.tap(side);
    await tester.pumpAndSettle();
    await tester.tap(find.text('pickup').last);
    await tester.pumpAndSettle();
    expect(c.openedId, 'pickup-expense');
    expect(find.byType(ExpenseDetailScreen), findsOneWidget);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.binding.setSurfaceSize(null);
  });

  testWidgets('linked food order opens its expense instead of being selected', (
    tester,
  ) async {
    String? opened;
    Set<String>? applied;
    final capture = GlobalKey();
    await tester.binding.setSurfaceSize(const Size(390, 844));
    final preview = MaterialApp(
      debugShowCheckedModeBanner: false,
      builder: (context, child) =>
          Theme(data: ExpenseDesign.theme(context), child: child!),
      home: Scaffold(
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: ExpenseOrderDropdown(
            orders: const [
              {
                '_id': 'order-1',
                'orderid': 'T2P-1001',
                'vendor_city': {'name': 'KOLKATA'},
                'timeslot': 'After Noon (12:00 PM - 04:00 PM)',
                'order_city': {'name': 'PUNE'},
                'delivery_date': '2026-10-28',
                'expense': {
                  '_id': 'expense-1',
                  'expense_no': 'FP-2627-000012',
                  'status': 'draft',
                },
              },
              {
                '_id': 'order-2',
                'orderid': 'T2P-1002',
                'vendor_city': {'name': 'KOLKATA'},
                'order_city': {'name': 'DELHI'},
                'delivery_date': '2026-10-29',
              },
            ],
            selected: const {},
            onSearch: (_) async {},
            onApply: (v) => applied = v,
            onOpenExpense: (v) => opened = v,
          ),
        ),
      ),
    );
    await tester.pumpWidget(RepaintBoundary(key: capture, child: preview));
    await tester.tap(find.byKey(const ValueKey('expense-order-dropdown')));
    await tester.pumpAndSettle();
    expect(find.byType(CheckboxListTile), findsNothing);
    expect(find.text('Delivery city: PUNE'), findsOneWidget);
    expect(find.text('Delivery date: 2026-10-28'), findsOneWidget);
    if (const bool.fromEnvironment('EXPENSE_DROPDOWN_CAPTURE')) {
      final boundary =
          capture.currentContext!.findRenderObject()! as RenderRepaintBoundary;
      await tester.runAsync(() async {
        final image = await boundary.toImage(pixelRatio: 2);
        final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
        await Directory('tmp').create(recursive: true);
        await File('tmp/expense-order-dropdown.png')
            .writeAsBytes(bytes!.buffer.asUint8List());
      });
    }
    await tester.tap(find.text('T2P-1001'));
    await tester.pumpAndSettle();
    expect(opened, isNull);
    await tester.tap(find.text('Open expense'));
    await tester.pumpAndSettle();
    expect(opened, 'expense-1');
    expect(applied, isNull);
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.binding.setSurfaceSize(null);
  });

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
