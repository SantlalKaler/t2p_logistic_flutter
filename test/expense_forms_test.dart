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
  List<Map<String, dynamic>> purchaseLines = [];
  String? openedId;
  bool returnSavedRecord = false;
  final List<int?> submittedVersions = [];
  ExpenseApiException? submitFailure;
  String saveError = '';
  @override
  Future<List<Map<String, dynamic>>> lookup(
    String name, {
    Map<String, dynamic>? query,
  }) async => lookupOrders;
  @override
  Future<Map<String, dynamic>> lookupData(
    String name, {
    Map<String, dynamic>? query,
  }) async => name == 'food-purchase-lines'
      ? {'lines': purchaseLines}
      : {'km': null, 'message': 'Not available'};
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
    error = saveError;
    if (returnSavedRecord) {
      return ExpenseDetail.fromJson({
        'expense': {
          '_id': id,
          'category': 'PETROL',
          'business_date': expenseToday(),
          'status': 'draft',
          'details': body['details'],
          'version': (body['version'] as int) + 1,
        },
        'actions': {'edit': true, 'submit': true},
      });
    }
    return null;
  }

  @override
  Future<ExpenseDetail> action(
    ExpenseDetail detail,
    String action, {
    String? reason,
  }) async {
    submittedVersions.add(detail.expense.version);
    if (submitFailure != null) throw submitFailure!;
    return detail;
  }

  @override
  Future<void> getExpenseList({int nextPage = 1}) async {}

  @override
  Future<void> loadLedger({
    int nextPage = 1,
    String from = '',
    String to = '',
    String type = '',
  }) async {}
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
    bool canSubmit = false,
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
        'actions': {'edit': true, 'submit': canSubmit},
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

  for (final readings in <Map<String, dynamic>>[
    {},
    {'start_km': 0},
    {'end_km': 15310.5},
    {'start_km': 15230, 'end_km': 15310.5},
  ]) {
    testWidgets('petrol Submit accepts optional readings $readings', (
      tester,
    ) async {
      final c = await recordSaves();
      await open(tester, 'PETROL', {
        'rate_per_litre': 10000,
        'litres': 1,
        ...readings,
      }, canSubmit: true);
      await tester.tap(find.byKey(const ValueKey('expense-save-submit')));
      await tester.pumpAndSettle();
      final details = expenseMap(c.saved?['details']);
      expect(details['rate_per_litre'], '100.00');
      for (final key in ['start_km', 'end_km']) {
        if (readings.containsKey(key)) {
          expect(details[key], '${readings[key]}');
        } else {
          expect(details.containsKey(key), false);
        }
      }
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.binding.setSurfaceSize(null);
    });
  }
  testWidgets('petrol refuses end below start and allows correcting it', (
    tester,
  ) async {
    final c = await recordSaves();
    await open(tester, 'PETROL', {
      'rate_per_litre': 10000,
      'litres': 1,
      'start_km': 100,
      'end_km': 90,
    }, canSubmit: true);
    await tester.tap(find.byKey(const ValueKey('expense-save-submit')));
    await tester.pumpAndSettle();
    expect(c.saved, isNull);
    expect(find.text("End km can't be lower than start km"), findsWidgets);
    final field = find.widgetWithText(TextFormField, 'End odometer (km)');
    await tester.ensureVisible(field);
    await tester.enterText(field, '100.1');
    tester.testTextInput.hide();
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('expense-save-submit')));
    await tester.pumpAndSettle();
    expect(expenseMap(c.saved?['details'])['end_km'], '100.1');
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.binding.setSurfaceSize(null);
  });

  testWidgets(
    'incomplete Food Purchase keeps blank rate and defaults to 5 percent GST',
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
            'gst_rate_bp': 500,
            'order_quantity': 2,
          },
        ],
      });
      expect(find.widgetWithText(TextFormField, 'GST (%)'), findsNothing);
      await tester.tap(find.byKey(const ValueKey('expense-save-draft')));
      await tester.pumpAndSettle();
      final details = expenseMap(c.saved?['details']);
      expect(details.containsKey('gst_applicable'), false);
      expect(details.containsKey('gst_percent'), false);
      expect(expenseMaps(details['items']).single['gst_applicable'], true);
      expect(expenseMaps(details['items']).single.containsKey('rate'), false);
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.binding.setSurfaceSize(null);
    },
  );

  testWidgets('five combined products submit with rounded automatic weights', (
    tester,
  ) async {
    final c = await recordSaves();
    c.meta['categories'] = [
      {'code': 'FOOD_PURCHASE', 'label': 'Food Purchase'},
    ];
    c.lookupOrders = [
      for (var i = 1; i <= 3; i++) {'_id': 'order-$i', 'orderid': 'T2P-$i'},
    ];
    c.purchaseLines = [
      for (var i = 0; i < 5; i++)
        {
          'product': 'product-$i',
          'product_name': 'Product $i',
          'unit_weight_kg': 0.1,
          'order_quantity': 3,
          'orders': [
            // The third selected order has no product provenance entries.
            for (var j = 1; j <= 2; j++)
              {'order': 'order-$j', 'orderid': 'T2P-$j', 'quantity': j},
          ],
        },
    ];
    await tester.binding.setSurfaceSize(const Size(390, 844));
    await tester.pumpWidget(const GetMaterialApp(home: AddEditExpenseScreen()));
    await tester.pumpAndSettle();
    await tester.tap(find.byType(DropdownButtonFormField<String>).first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Food Purchase').last);
    await tester.pumpAndSettle();
    tester
        .widget<ExpenseOrderDropdown>(find.byType(ExpenseOrderDropdown))
        .onApply({'order-1', 'order-2', 'order-3'});
    await tester.pumpAndSettle();
    for (var i = 0; i < 5; i++) {
      final rate = find.byKey(ValueKey('details.items[$i]:rate:product-$i'));
      await tester.ensureVisible(rate);
      await tester.enterText(rate, '${150 + i}');
      tester.testTextInput.hide();
      await tester.pumpAndSettle();
    }
    await tester.tap(find.byKey(const ValueKey('expense-save-submit')));
    await tester.pumpAndSettle();
    expect(c.saved, isNotNull);
    expect(c.saved!['submit'], true);
    expect(expenseMap(c.saved!['details'])['orders'], [
      'order-1',
      'order-2',
      'order-3',
    ]);
    final items = expenseMaps(expenseMap(c.saved!['details'])['items']);
    expect(items.length, 5);
    expect(items.map((e) => e['rate']), ['150', '151', '152', '153', '154']);
    expect(items.map((e) => e['weight_kg']), everyElement('0.300'));
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.binding.setSurfaceSize(null);
  });

  testWidgets('save errors return to the top of a long purchase form', (
    tester,
  ) async {
    final c = await recordSaves();
    c.saveError = 'Order is already linked to another purchase';
    await open(tester, 'FOOD_PURCHASE', {
      'orders': ['order-1'],
      'items': [
        for (var i = 0; i < 5; i++)
          {
            'product': 'p$i',
            'product_name': 'Product $i',
            'rate': 10000,
            'order_quantity': 1,
          },
      ],
    });
    await tester.ensureVisible(find.text('Grand total: \u20b9500.00'));
    await tester.tap(find.byKey(const ValueKey('expense-save-draft')));
    await tester.pumpAndSettle();
    expect(find.text(c.saveError).hitTestable(), findsOneWidget);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.binding.setSurfaceSize(null);
  });

  testWidgets('reopening orders reloads upcoming dates and clears old search', (
    tester,
  ) async {
    final tomorrow = expenseDay(
      DateTime.parse(expenseToday()).add(const Duration(days: 1)),
    );
    final queries = <String>[];
    var orders = <Map<String, dynamic>>[];
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: StatefulBuilder(
            builder: (context, set) {
              return Padding(
                padding: const EdgeInsets.all(24),
                child: ExpenseOrderDropdown(
                  orders: orders,
                  selected: const {'one'},
                  onApply: (_) {},
                  onSearch: (q) async {
                    queries.add(q);
                    set(
                      () => orders = q.isEmpty
                          ? [
                              {
                                '_id': 'one',
                                'orderid': 'T2P-1001',
                                'delivery_date': tomorrow,
                              },
                            ]
                          : [],
                    );
                  },
                ),
              );
            },
          ),
        ),
      ),
    );
    await tester.tap(find.byKey(const ValueKey('expense-order-dropdown')));
    await tester.pumpAndSettle();
    expect(find.text('Delivery date: $tomorrow'), findsOneWidget);
    await tester.enterText(find.byType(TextField), 'missing');
    await tester.testTextInput.receiveAction(TextInputAction.search);
    await tester.pumpAndSettle();
    expect(find.text('No orders found'), findsOneWidget);
    await tester.tap(find.text('Apply'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('expense-order-dropdown')));
    await tester.pumpAndSettle();
    expect(queries, ['', 'missing', '']);
    expect(find.text('Delivery date: $tomorrow'), findsOneWidget);
    expect(find.text('1/50 selected'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

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
          'gst_rate_bp': 500,
          'order_quantity': 2,
        },
      ],
    });
    expect(find.text('Grand total: \u20b9210.00'), findsOneWidget);
    expect(find.text('Total: \u20b9210.00'), findsOneWidget);
    final gst = find.byType(DropdownButtonFormField<bool>);
    await tester.ensureVisible(gst);
    await tester.pumpAndSettle();
    await tester.tap(gst);
    await tester.pumpAndSettle();
    await tester.tap(find.text('No').last);
    await tester.pumpAndSettle();
    expect(find.text('Grand total: \u20b9200.00'), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('expense-save-draft')));
    await tester.pumpAndSettle();
    expect(
      expenseMaps(expenseMap(c.saved?['details'])['items'])
          .single['gst_applicable'],
      false,
    );
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.binding.setSurfaceSize(null);
  });

  testWidgets('saved mixed GST stays independent when prices and GST change', (
    tester,
  ) async {
    final c = await recordSaves();
    await open(tester, 'FOOD_PURCHASE', {
      'orders': ['order-1'],
      // Purchase summaries must never override the individual products.
      'gst_applicable': false,
      'gst_rate_bp': 0,
      'items': [
        {
          'product': 'p1',
          'product_name': 'Biryani',
          'rate': 10000,
          'order_quantity': 5,
          'gst_rate_bp': 500,
        },
        {
          'product': 'p2',
          'product_name': 'Chaap',
          'rate': 10000,
          'order_quantity': 1,
          'gst_rate_bp': 0,
        },
        {
          'product': 'p3',
          'product_name': 'Rasgulla',
          'rate': 10000,
          'order_quantity': 2,
          'gst_rate_bp': 500,
        },
      ],
    });
    expect(find.text('Grand total: \u20b9835.00'), findsOneWidget);
    final chaap = find.byKey(const ValueKey('food-line:p2'));
    final price = find
        .descendant(of: chaap, matching: find.byType(TextFormField))
        .first;
    await tester.ensureVisible(price);
    await tester.enterText(price, '200');
    tester.testTextInput.hide();
    await tester.pumpAndSettle();
    expect(find.text('Grand total: \u20b9935.00'), findsOneWidget);
    final biryani = find.byKey(const ValueKey('food-line:p1'));
    final gst = find.descendant(
      of: biryani,
      matching: find.byType(DropdownButtonFormField<bool>),
    );
    await tester.ensureVisible(gst);
    await tester.pumpAndSettle();
    await tester.tap(gst);
    await tester.pumpAndSettle();
    await tester.tap(find.text('No').last);
    await tester.pumpAndSettle();
    expect(find.text('Grand total: \u20b9910.00'), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('expense-save-draft')));
    await tester.pumpAndSettle();
    final items = expenseMaps(expenseMap(c.saved?['details'])['items']);
    expect(items.map((e) => e['gst_applicable']), [false, false, true]);
    expect(items[1]['rate'], '200');
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.binding.setSurfaceSize(null);
  });

  testWidgets(
    'fresh purchase lines keep server order, blank prices and default GST',
    (tester) async {
      final c = await recordSaves();
      c.purchaseLines = [
        {
          'product': 'z',
          'product_name': 'Z product',
          'order_quantity': 1,
          'rate': 99999,
        },
        {
          'product': 'a',
          'product_name': 'A product',
          'order_quantity': 2,
          'rate': 99999,
        },
      ];
      await open(tester, 'FOOD_PURCHASE', {
        'orders': ['order-1'],
        'items': [],
      });
      await tester.ensureVisible(find.text('Refresh product lines'));
      await tester.tap(find.text('Refresh product lines'));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('expense-save-draft')));
      await tester.pumpAndSettle();
      final items = expenseMaps(expenseMap(c.saved?['details'])['items']);
      expect(items.map((e) => e['product']), ['z', 'a']);
      expect(items.every((e) => !e.containsKey('rate')), true);
      expect(items.every((e) => e['gst_applicable'] == true), true);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.binding.setSurfaceSize(null);
    },
  );

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

  testWidgets('GST preview uses metadata and leaves untaxed rows unchanged', (
    tester,
  ) async {
    final c = await recordSaves();
    c.meta['gst_rate_percent'] = 12;
    await open(tester, 'FOOD_PURCHASE', {
      'orders': ['order-1'],
      'items': [
        {
          'product': 'p1',
          'product_name': 'Biryani',
          'order_quantity': 2,
          'rate': 10000,
          'gst_rate_bp': 500,
        },
        {
          'product': 'p2',
          'product_name': 'Sweets',
          'order_quantity': 1,
          'rate': 10000,
          'gst_rate_bp': 0,
        },
      ],
    });
    expect(find.text('Total: \u20b9224.00'), findsOneWidget);
    expect(find.text('Total: \u20b9100.00'), findsOneWidget);
    expect(find.text('Grand total: \u20b9324.00'), findsOneWidget);
    expect(find.text('Yes (12%)'), findsWidgets);
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.binding.setSurfaceSize(null);
  });

  testWidgets(
    'date errors are beside the date control and clear after selection',
    (tester) async {
      await recordSaves();
      await open(
        tester,
        'PETROL',
        {},
        incomplete: [
          {
            'field': 'details.filled_at',
            'message': 'Choose an allowed filling date',
          },
        ],
      );
      final date = find.byKey(
        const ValueKey('expense-date:Filling date (optional)'),
      );
      await tester.ensureVisible(date);
      await tester.pumpAndSettle();
      final decorator = find.descendant(
        of: date,
        matching: find.byType(InputDecorator),
      );
      expect(
        tester.widget<InputDecorator>(decorator).decoration.errorText,
        'Choose an allowed filling date',
      );
      await tester.tap(date);
      await tester.pumpAndSettle();
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();
      expect(
        tester.widget<InputDecorator>(decorator).decoration.errorText,
        isNull,
      );
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.binding.setSurfaceSize(null);
    },
  );

  testWidgets(
    'editing a negative adjustment replaces it without double counting',
    (tester) async {
      final c = await recordSaves();
      await open(
        tester,
        'FOOD_PURCHASE',
        {
          'orders': ['order-1'],
          'items': [
            {
              'product': 'p1',
              'product_name': 'Biryani',
              'order_quantity': 5,
              'rate': 10000,
              'gst_rate_bp': 500,
              'adjustments': [
                {'quantity': -4, 'note': 'Only one available'},
              ],
            },
          ],
        },
        incomplete: [
          {
            'field': 'details.items[0].adjustments[0].note',
            'message': 'Explain the change',
          },
        ],
      );
      final edit = find.byTooltip('Edit adjustment');
      await tester.ensureVisible(edit);
      await tester.pumpAndSettle();
      await tester.tap(edit);
      await tester.pumpAndSettle();
      expect(find.text('4'), findsOneWidget);
      final reason = find.widgetWithText(TextFormField, 'Reason');
      expect(
        tester
            .widget<TextField>(
              find.descendant(of: reason, matching: find.byType(TextField)),
            )
            .decoration!
            .errorText,
        'Explain the change',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Quantity'),
        '3',
      );
      await tester.enterText(reason, 'Two available now');
      tester.testTextInput.hide();
      await tester.tap(find.text('Save adjustment'));
      await tester.pumpAndSettle();
      expect(find.text('Qty: 2'), findsOneWidget);
      await tester.tap(find.byKey(const ValueKey('expense-save-draft')));
      await tester.pumpAndSettle();
      final entry = expenseMaps(
        expenseMaps(expenseMap(c.saved!['details'])['items'])
            .single['adjustments'],
      ).single;
      expect(entry['quantity'], '-3');
      expect(entry['note'], 'Two available now');
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.binding.setSurfaceSize(null);
    },
  );

  testWidgets(
    'incomplete food usage can be completed in place even when none is left',
    (tester) async {
      final c = await recordSaves();
      await open(
        tester,
        'CANCELLED_ORDER',
        {
          'order': 'order-1',
          'items': [
            {
              'line_id': 'line-1',
              'product': 'p1',
              'product_name': 'Biryani',
              'quantity': 3,
              'dispositions': [
                {'type': 'consumed', 'quantity': 3, 'date': expenseToday()},
              ],
            },
          ],
        },
        incomplete: [
          {
            'field': 'details.items[0].dispositions[0].note',
            'message': 'Enter who consumed the food',
          },
        ],
      );
      final edit = find.byTooltip('Edit food usage');
      await tester.ensureVisible(edit);
      await tester.pumpAndSettle();
      await tester.tap(edit);
      await tester.pumpAndSettle();
      expect(find.text('Available quantity: 3'), findsOneWidget);
      final note = find.byKey(const ValueKey('food-usage-note'));
      expect(
        tester
            .widget<TextField>(
              find.descendant(of: note, matching: find.byType(TextField)),
            )
            .decoration!
            .errorText,
        'Enter who consumed the food',
      );
      await tester.ensureVisible(note);
      await tester.enterText(note, 'Office team');
      tester.testTextInput.hide();
      await tester.tap(find.text('Save usage'));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('expense-save-draft')));
      await tester.pumpAndSettle();
      final entry = expenseMaps(
        expenseMaps(expenseMap(c.saved!['details'])['items'])
            .single['dispositions'],
      ).single;
      expect(entry['quantity'], '3');
      expect(entry['note'], 'Office team');
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.binding.setSurfaceSize(null);
    },
  );

  testWidgets(
    'edit then submit uses the saved version and keeps a failed submission editable',
    (tester) async {
      final c = await recordSaves();
      c.returnSavedRecord = true;
      c.submitFailure = ExpenseApiException(
        422,
        'Please correct the reading',
        fields: {'details.start_km': 'Reading required'},
      );
      await open(tester, 'PETROL', {
        'rate_per_litre': 10477,
        'litres': 3.25,
        'start_km': 15230,
      }, canSubmit: true);
      await tester.tap(find.byKey(const ValueKey('expense-save-submit')));
      await tester.pumpAndSettle();
      expect(c.saved!['version'], 2);
      expect(c.saved!.containsKey('submit'), false);
      expect(c.submittedVersions, [3]);
      expect(
        find.textContaining('Changes saved. Submission failed:'),
        findsOneWidget,
      );
      final reading = find.widgetWithText(TextFormField, 'Start odometer (km)');
      expect(
        tester
            .widget<TextField>(
              find.descendant(of: reading, matching: find.byType(TextField)),
            )
            .decoration!
            .errorText,
        'Reading required',
      );
      // A second attempt must PATCH using version 3, rather than the original 2.
      await tester.tap(find.byKey(const ValueKey('expense-save-submit')));
      await tester.pumpAndSettle();
      expect(c.saved!['version'], 3);
      expect(c.submittedVersions, [3, 4]);
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.binding.setSurfaceSize(null);
    },
  );

  testWidgets(
    'Save and submit resubmits an edited rejected expense and returns to details',
    (tester) async {
      final c = await recordSaves();
      c.returnSavedRecord = true;
      final detail = ExpenseDetail.fromJson({
        'expense': {
          '_id': 'rejected-expense',
          'category': 'PETROL',
          'status': 'rejected',
          'business_date': expenseToday(),
          'version': 8,
          'details': {
            'rate_per_litre': 10477,
            'litres': 3.25,
            'start_km': 15230,
          },
        },
        'actions': {'edit': true, 'submit': true},
      });
      await tester.binding.setSurfaceSize(const Size(390, 844));
      await tester.pumpWidget(
        GetMaterialApp(
          home: Scaffold(
            body: TextButton(
              onPressed: () =>
                  Get.to(() => AddEditExpenseScreen(expense: detail)),
              child: const Text('Open expense'),
            ),
          ),
        ),
      );
      await tester.tap(find.text('Open expense'));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('expense-save-submit')));
      await tester.pumpAndSettle();
      expect(c.saved!['version'], 8);
      expect(c.submittedVersions, [9]);
      expect(find.byType(AddEditExpenseScreen), findsNothing);
      expect(find.text('Open expense'), findsOneWidget);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.binding.setSurfaceSize(null);
    },
  );

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
