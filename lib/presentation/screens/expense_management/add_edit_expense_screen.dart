import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:uuid/uuid.dart';

import '../../../domain/Model/expense/expense_v1.dart';
import 'expense_controller.dart';
import 'expense_detail.dart';
import 'components/expense_order_dropdown.dart';
import 'components/expense_order_info.dart';
import 'components/expense_design.dart';
import 'components/food_usage_dialog.dart';

class AddEditExpenseScreen extends StatefulWidget {
  final ExpenseDetail? expense;
  const AddEditExpenseScreen({super.key, this.expense});
  @override
  State<AddEditExpenseScreen> createState() => _AddEditExpenseScreenState();
}

class _AddEditExpenseScreenState extends State<AddEditExpenseScreen> {
  final ExpenseController c = Get.find();
  final form = GlobalKey<FormState>();
  final fields = <String, TextEditingController>{};
  final requestId = const Uuid().v4();
  String category = '',
      date = expenseToday(),
      head = '',
      mode = '',
      order = '',
      side = '';
  List<Map<String, dynamic>> cities = [], orders = [], lines = [];
  Set<String> selectedOrders = {};
  final orderCatalog = <String, Map<String, dynamic>>{};
  bool loading = true, saving = false, ordersChanged = false;
  String error = '', lookupQuery = '';
  Map<String, String> serverErrors = {};
  Map<String, dynamic>? distance;
  bool validatingSubmit = false, gstApplicable = true;
  int lookupGeneration = 0;
  ExpenseDetail? currentExpense;
  bool get editing => currentExpense != null;
  Map<String, dynamic> get original => currentExpense?.expense.details ?? {};
  TextEditingController field(String name) =>
      fields.putIfAbsent(name, () => TextEditingController());
  List<Map<String, dynamic>> get categories =>
      expenseMaps(c.meta['categories']);

  @override
  void initState() {
    super.initState();
    currentExpense = widget.expense;
    initialize();
  }

  @override
  void dispose() {
    scroll.dispose();
    for (final f in fields.values) {
      f.dispose();
    }
    super.dispose();
  }

  Future<void> initialize() async {
    c.fieldErrors = {};
    try {
      if (c.meta.isEmpty) {
        c.meta = expenseMap(
          (await c.request('${ExpenseController.base}/meta'))['data'],
        );
      }
      if (editing) {
        serverErrors = {
          for (final e in currentExpense!.expense.incomplete)
            '${e['field']}': '${e['message']}',
        };
        category = currentExpense!.expense.category;
        date = currentExpense!.expense.date;
        field('notes').text = '${currentExpense!.expense.json['notes'] ?? ''}';
        for (final e in original.entries) {
          if (e.value is String || e.value is num) {
            field(e.key).text = '${e.value}';
          }
        }
        for (final money in ['amount', 'rate_per_kg', 'rate_per_litre']) {
          if (original[money] != null) {
            field(money).text = expenseRupees(original[money]);
          }
        }
        for (final key in ['filled_at', 'journey_date']) {
          if (original[key] != null) {
            field(key).text = expenseDay(original[key]);
          }
        }
        head = expenseId(original['expense_head']);
        if (head.isEmpty && '${original['head_other'] ?? ''}'.isNotEmpty) {
          head = 'other';
        }
        mode = '${original['travel_mode'] ?? ''}';
        order = expenseId(original['order']);
        side = '${original['side'] ?? ''}';
        if (category == 'FOOD_PURCHASE') {
          selectedOrders = (original['orders'] as List? ?? [])
              .map(expenseId)
              .toSet();
          lines = expenseMaps(jsonDecode(jsonEncode(original['items'])));
          gstApplicable = original['gst_applicable'] != false;
          for (final line in lines) {
            line['rate'] = line['rate'] == null
                ? ''
                : expenseRupees(line['rate']);
            line['discount_value'] =
                (expenseNumber(line['discount_value']) / 100).toString();
          }
        } else if (category == 'CANCELLED_ORDER') {
          lines = expenseMaps(jsonDecode(jsonEncode(original['items'])));
        }
        await loadCategory();
      }
    } catch (e) {
      error = '$e';
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  Future<void> changeCategory(String value) async {
    setState(() {
      category = value;
      lookupQuery = '';
      lookupGeneration++;
      head = '';
      mode = '';
      order = '';
      side = '';
      lines = [];
      orders = [];
      selectedOrders = {};
      distance = null;
      error = '';
      serverErrors = {};
      loading = true;
      for (final e in fields.entries) {
        if (e.key != 'notes') e.value.clear();
      }
    });
    try {
      gstApplicable = true;
      await loadCategory();
    } catch (e) {
      error = '$e';
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  Future<void> loadCategory() async {
    if (category == 'INTERCITY_LOGISTICS') {
      cities = await c.lookup('cities');
      field('from_city').text = expenseId(original['from_city']).isNotEmpty
          ? expenseId(original['from_city'])
          : '${expenseMap(c.meta['me'])['default_city'] ?? ''}';
      if (editing) field('to_city').text = expenseId(original['to_city']);
    }
    if (['FOOD_PURCHASE', 'DELIVERY', 'CANCELLED_ORDER'].contains(category)) {
      await findOrders();
      if (editing && category == 'DELIVERY') await loadDistance();
    }
  }

  Future<void> findOrders() async {
    final generation = ++lookupGeneration;
    final name = category == 'FOOD_PURCHASE'
        ? 'food-purchase-orders'
        : category == 'CANCELLED_ORDER'
        ? 'cancelled-orders'
        : 'orders';
    final result = await c.lookup(
      name,
      query: {if (lookupQuery.isNotEmpty) 'q': lookupQuery},
    );
    if (!mounted || generation != lookupGeneration) return;
    for (final item in result) {
      orderCatalog[expenseId(item)] = item;
    }
    final retained = orders
        .where(
          (e) => selectedOrders.contains(expenseId(e)) || expenseId(e) == order,
        )
        .toList();
    orders = [
      ...result,
      ...retained.where(
        (e) => !result.any((r) => expenseId(r) == expenseId(e)),
      ),
    ];
    // Active records may be excluded by the lookup; preserve the current selection when editing.
    if (editing && category == 'FOOD_PURCHASE') {
      for (final ref in expenseMaps(
        currentExpense!.expense.json['order_refs'],
      )) {
        final id = expenseId(ref['order']);
        if (!orders.any((e) => expenseId(e) == id)) {
          orders.add({'_id': id, 'orderid': ref['orderid']});
        }
      }
    } else if (editing &&
        order.isNotEmpty &&
        !orders.any((e) => expenseId(e) == order)) {
      final refs = expenseMaps(currentExpense!.expense.json['order_refs']);
      orders.add({
        '_id': order,
        'orderid': refs.isEmpty ? order : refs.first['orderid'],
        'sides': [side],
      });
    }
  }

  Future<void> loadDistance() async {
    if (order.isEmpty) return;
    distance = await c.lookupData(
      'orders/$order/default-distance',
      query: {if (side.isNotEmpty) 'side': side},
    );
  }

  Future<void> selectOrder(String id) async {
    setState(() {
      order = id;
      distance = null;
      loading = true;
      error = '';
    });
    try {
      final selected = orders.firstWhere((e) => expenseId(e) == id);
      final sides = selected['sides'] as List? ?? [];
      side = category == 'DELIVERY' && sides.length > 1
          ? ''
          : '${selected['side'] ?? ''}';
      if (category == 'DELIVERY') {
        if (side.isNotEmpty && !await openDeliveryExpense()) {
          await loadDistance();
        }
      } else {
        lines = expenseMaps(jsonDecode(jsonEncode(selected['products'])));
        for (final line in lines) {
          line['dispositions'] = <Map<String, dynamic>>[];
        }
      }
    } catch (e) {
      error = '$e';
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  Future<void> openExistingExpense(String id) async {
    await Get.to(() => ExpenseDetailScreen(id: id));
    if (!mounted) return;
    await findOrders();
    if (mounted) setState(() {});
  }

  Future<bool> openDeliveryExpense() async {
    final selected = orders.where((e) => expenseId(e) == order).firstOrNull;
    final existing = expenseMaps(selected?['expenses'])
        .where(
          (e) =>
              e['side'] == side && expenseId(e) != currentExpense?.expense.id,
        )
        .firstOrNull;
    if (existing == null) return false;
    await openExistingExpense(expenseId(existing));
    if (mounted) {
      setState(() {
        order = '';
        side = '';
        distance = null;
      });
    }
    return true;
  }

  num foodLineTaxPaise(Map<String, dynamic> line) {
    final subtotal = expenseNumber(line['rate']) * finalQuantity(line);
    final discount = line['discount_type'] == 'percent'
        ? subtotal * expenseNumber(line['discount_value']) / 100
        : expenseNumber(line['discount_value']);
    return gstApplicable
        ? (subtotal - discount).clamp(0, double.infinity) * 5
        : 0;
  }

  int foodPreviewPaise() {
    num total = 0;
    for (final line in lines) {
      final subtotal = expenseNumber(line['rate']) * finalQuantity(line);
      final discount = line['discount_type'] == 'percent'
          ? subtotal * expenseNumber(line['discount_value']) / 100
          : expenseNumber(line['discount_value']);
      final taxable = (subtotal - discount).clamp(0, double.infinity);
      total += taxable + (gstApplicable ? taxable * 5 / 100 : 0);
    }
    return (total * 100).round();
  }

  Future<void> foodLines() async {
    setState(() {
      loading = true;
      error = '';
    });
    try {
      final response = await c.lookupData(
        'food-purchase-lines',
        query: {'orders': selectedOrders.join(',')},
      );
      final fresh = expenseMaps(response['lines']);
      // Keep user inputs when the selected orders still contain the same product.
      for (final line in fresh) {
        final previous = lines
            .where((e) => expenseId(e['product']) == expenseId(line['product']))
            .firstOrNull;
        for (final key in [
          'rate',
          'weight_kg',
          'discount_type',
          'discount_value',
          'adjustments',
        ]) {
          if (previous?[key] != null) line[key] = previous![key];
        }
        line.putIfAbsent(
          'weight_kg',
          () =>
              expenseNumber(line['unit_weight_kg']) *
              expenseNumber(line['order_quantity']),
        );
      }
      lines = fresh;
      ordersChanged = true;
    } catch (e) {
      error = '$e';
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  String? validateNumber(
    String? value,
    int decimals, {
    bool required = true,
    bool zero = false,
  }) {
    if ((value ?? '').trim().isEmpty) {
      return required && validatingSubmit ? 'Required' : null;
    }
    final number = num.tryParse(value!);
    if (number == null ||
        !number.isFinite ||
        (zero ? number < 0 : number <= 0)) {
      return zero
          ? 'Enter zero or a positive number'
          : 'Enter a positive number';
    }
    if (!RegExp('^\\d+(\\.\\d{1,$decimals})?\$').hasMatch(value)) {
      return 'Maximum $decimals decimal places';
    }
    return null;
  }

  Widget text(
    String name,
    String label, {
    bool required = true,
    int? decimals,
    bool zero = false,
    int maxLength = 1000,
    int lines = 1,
  }) => Padding(
    padding: const EdgeInsets.only(bottom: 14),
    child: TextFormField(
      controller: field(name),
      onChanged: (_) {
        setState(() => serverErrors.remove('details.$name'));
      },
      maxLines: lines,
      maxLength: maxLength,
      keyboardType: decimals == null
          ? TextInputType.text
          : const TextInputType.numberWithOptions(decimal: true),
      decoration: InputDecoration(
        labelText: label,
        counterText: '',
        errorText: serverErrors['details.$name'] ?? serverErrors[name],
      ),
      validator: (v) => decimals != null
          ? validateNumber(v, decimals, required: required, zero: zero)
          : validatingSubmit && required && (v ?? '').trim().isEmpty
          ? 'Required'
          : null,
    ),
  );
  Widget dropdown(
    String label,
    String value,
    List<MapEntry<String, String>> options,
    ValueChanged<String> changed, {
    String? errorKey,
    bool requiredForDraft = false,
    Map<String, Widget>? optionWidgets,
  }) {
    final unique = <String, String>{for (final e in options) e.key: e.value};
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: DropdownButtonFormField<String>(
        key: ValueKey('$label:$value:${unique.keys.join(',')}'),
        initialValue: unique.containsKey(value) ? value : null,
        isExpanded: true,
        itemHeight: optionWidgets == null ? kMinInteractiveDimension : null,
        selectedItemBuilder: optionWidgets == null
            ? null
            : (context) => [
                for (final label in unique.values)
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(label, overflow: TextOverflow.ellipsis),
                  ),
              ],
        decoration: InputDecoration(
          labelText: label,
          errorText: serverErrors[errorKey],
        ),
        items: unique.entries
            .map(
              (e) => DropdownMenuItem(
                value: e.key,
                child:
                    optionWidgets?[e.key] ??
                    Text(e.value, overflow: TextOverflow.ellipsis),
              ),
            )
            .toList(),
        onChanged: loading || saving
            ? null
            : (v) {
                if (v != null) changed(v);
              },
        validator: (v) =>
            (validatingSubmit || requiredForDraft) && (v ?? '').isEmpty
            ? 'Required'
            : null,
      ),
    );
  }

  Widget dateInput(String label, String current, ValueChanged<String> change) =>
      Padding(
        padding: const EdgeInsets.only(bottom: 14),
        child: InkWell(
          key: ValueKey('expense-date:$label'),
          borderRadius: BorderRadius.circular(12),
          onTap: saving || loading
              ? null
              : () async {
                  final today = DateTime.parse(expenseToday());
                  final earliest = today.subtract(
                    Duration(
                      days: expenseNumber(c.meta['backdate_days'] ?? 7).toInt(),
                    ),
                  );
                  final parsed = DateTime.tryParse(current) ?? today;
                  final chosen = await showDatePicker(
                    context: context,
                    initialDate:
                        parsed.isBefore(earliest) || parsed.isAfter(today)
                        ? today
                        : parsed,
                    firstDate: earliest,
                    lastDate: today,
                  );
                  if (chosen != null && mounted) {
                    setState(() => change(expenseDay(chosen)));
                  }
                },
          child: InputDecorator(
            decoration: InputDecoration(
              labelText: label,
              prefixIcon: const Icon(Icons.calendar_today_outlined, size: 20),
              suffixIcon: const Icon(Icons.keyboard_arrow_down_rounded),
            ),
            child: Text(
              current.isEmpty ? 'Select date' : current,
              style: const TextStyle(
                fontFamily: 'Roboto',
                fontSize: 14,
                color: ink,
              ),
            ),
          ),
        ),
      );
  static const accent = Color(0xFFB42332);
  static const ink = Color(0xFF182230);
  static const muted = Color(0xFF667085);
  final scroll = ScrollController();

  IconData get categoryIcon => switch (category) {
    'FOOD_PURCHASE' => Icons.restaurant_outlined,
    'INTERCITY_LOGISTICS' => Icons.local_shipping_outlined,
    'DELIVERY' => Icons.delivery_dining_outlined,
    'PETROL' => Icons.local_gas_station_outlined,
    'TRAVEL' => Icons.route_outlined,
    'CANCELLED_ORDER' => Icons.inventory_2_outlined,
    _ => Icons.receipt_long_outlined,
  };
  String get categoryTitle =>
      categories
          .where((e) => e['code'] == category)
          .firstOrNull?['label']
          ?.toString() ??
      currentExpense?.json['category_label']?.toString() ??
      const {
        'PETROL': 'Petrol Filling',
        'MISC': 'Miscellaneous',
        'TRAVEL': 'Travelling',
        'FOOD_PURCHASE': 'Food Purchase',
        'INTERCITY_LOGISTICS': 'Intercity Logistics',
        'DELIVERY': 'Delivery',
        'CANCELLED_ORDER': 'Cancelled Orders',
      }[category] ??
      category;

  Widget section({
    required String title,
    required IconData icon,
    required List<Widget> children,
    String? subtitle,
  }) => Container(
    margin: const EdgeInsets.only(bottom: 16),
    padding: const EdgeInsets.all(18),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      border: Border.all(color: const Color(0xFFEAECF0)),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(9),
              decoration: BoxDecoration(
                color: const Color(0xFFFDF0F1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, size: 19, color: accent),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontFamily: 'Roboto',
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: ink,
                    ),
                  ),
                  if (subtitle != null)
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontFamily: 'Roboto',
                        fontSize: 12,
                        color: muted,
                        height: 1.5,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        ...children,
      ],
    ),
  );

  @override
  Widget build(BuildContext context) => Theme(
    data: ExpenseDesign.theme(context),
    child: Builder(
      builder: (context) => Scaffold(
        appBar: AppBar(
          title: Text(editing ? 'Edit expense' : 'New expense'),
          leading: IconButton(
            tooltip: 'Back',
            onPressed: saving ? null : () => Get.back(),
            icon: const Icon(Icons.arrow_back_rounded),
          ),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(1),
            child: Container(height: 1, color: const Color(0xFFEAECF0)),
          ),
        ),
        bottomNavigationBar: Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.viewInsetsOf(context).bottom,
          ),
          child: actionBar(),
        ),
        body: AbsorbPointer(
          absorbing: saving,
          child: Form(
            key: form,
            child: ListView(
              key: const ValueKey('expense-form-scroll'),
              controller: scroll,
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
              children: [
                if (loading || saving)
                  const Padding(
                    padding: EdgeInsets.only(bottom: 16),
                    child: LinearProgressIndicator(minHeight: 3),
                  ),
                if (error.isNotEmpty)
                  Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFEF3F2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          error,
                          style: const TextStyle(
                            fontFamily: 'Roboto',
                            color: Color(0xFFB42318),
                            fontSize: 13,
                          ),
                        ),
                        if (!saving)
                          TextButton(
                            onPressed: () async {
                              setState(() {
                                loading = true;
                                error = '';
                              });
                              try {
                                if (c.meta.isEmpty) {
                                  await initialize();
                                } else {
                                  await loadCategory();
                                }
                              } catch (e) {
                                error = '$e';
                              } finally {
                                if (mounted) setState(() => loading = false);
                              }
                            },
                            child: const Text('Retry loading'),
                          ),
                      ],
                    ),
                  ),
                for (final entry in serverErrors.entries.where(
                  (e) =>
                      e.key.contains('[') ||
                      e.key == 'details.orders' ||
                      e.key == 'files',
                ))
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Text(
                      '${entry.key}: ${entry.value}',
                      style: const TextStyle(
                        fontFamily: 'Roboto',
                        color: Colors.red,
                      ),
                    ),
                  ),
                section(
                  title: 'Expense overview',
                  icon: Icons.receipt_long_outlined,
                  subtitle: 'Choose a type and the date of your expense.',
                  children: [
                    if (!editing)
                      dropdown(
                        'Expense type',
                        category,
                        [
                          for (final e in categories)
                            MapEntry('${e['code']}', '${e['label']}'),
                        ],
                        changeCategory,
                        errorKey: 'category',
                      )
                    else
                      Container(
                        padding: const EdgeInsets.all(14),
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFDF0F1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Icon(categoryIcon, color: accent, size: 22),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                categoryTitle,
                                style: const TextStyle(
                                  fontFamily: 'Roboto',
                                  fontWeight: FontWeight.w600,
                                  color: accent,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    dateInput('Expense date', date, (v) {
                      date = v;
                      serverErrors.remove('expense_date');
                    }),
                    if (serverErrors['expense_date'] != null)
                      Text(
                        serverErrors['expense_date']!,
                        style: const TextStyle(
                          fontFamily: 'Roboto',
                          color: Colors.red,
                        ),
                      ),
                  ],
                ),
                if (category.isNotEmpty) ...[
                  if (serverErrors.isNotEmpty) ...[
                    const Text(
                      'Please check these fields',
                      style: TextStyle(color: Colors.red),
                    ),
                    for (final message in serverErrors.values.toSet())
                      Text(message, style: const TextStyle(color: Colors.red)),
                  ],
                  section(
                    title: categoryTitle,
                    icon: categoryIcon,
                    subtitle: 'Add the details for this expense.',
                    children: categoryFields(),
                  ),
                  section(
                    title: 'Additional information',
                    icon: Icons.notes_rounded,
                    children: [
                      text(
                        'notes',
                        'Notes (optional)',
                        required: false,
                        lines: 3,
                      ),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(
                            Icons.attach_file_rounded,
                            size: 18,
                            color: muted,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Save a draft to attach bills, photos or PDFs.',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ] else
                  Container(
                    padding: const EdgeInsets.all(24),
                    child: const Column(
                      children: [
                        Icon(
                          Icons.edit_note_rounded,
                          size: 36,
                          color: Color(0xFF98A2B3),
                        ),
                        SizedBox(height: 10),
                        Text(
                          'Start with an expense type',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: muted,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'The details you need will appear here.',
                          style: TextStyle(fontSize: 12, color: muted),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    ),
  );

  Widget actionBar() {
    final enabled = category.isNotEmpty && !loading && !saving;
    final canSubmit = !editing && category != 'CANCELLED_ORDER';
    return Container(
      key: const ValueKey('expense-action-bar'),
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFEAECF0))),
        boxShadow: [
          BoxShadow(
            color: Color(0x06000000),
            blurRadius: 16,
            offset: Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Expanded(
                  child: canSubmit
                      ? OutlinedButton(
                          key: const ValueKey('expense-save-draft'),
                          onPressed: enabled ? () => save(false) : null,
                          child: const Text('Save draft'),
                        )
                      : FilledButton(
                          key: const ValueKey('expense-save-draft'),
                          onPressed: enabled ? () => save(false) : null,
                          child: saving
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : Text(editing ? 'Save changes' : 'Save draft'),
                        ),
                ),
                if (canSubmit) ...[
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton(
                      key: const ValueKey('expense-save-submit'),
                      onPressed: enabled ? () => save(true) : null,
                      child: saving
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text(
                              'Save and submit',
                              textAlign: TextAlign.center,
                            ),
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 8),
            Text(
              editing
                  ? 'Changes stay in draft until you submit.'
                  : category == 'CANCELLED_ORDER'
                  ? 'Save first. Approve the record when complete.'
                  : 'Save for later or send for approval.',
              style: const TextStyle(
                fontFamily: 'Roboto',
                fontSize: 11,
                color: muted,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> categoryFields() {
    switch (category) {
      case 'INTERCITY_LOGISTICS':
        final from = field('from_city').text;
        final fromName = cities
            .where((e) => expenseId(e) == from)
            .firstOrNull?['name'];
        return [
          ListTile(
            title: const Text('From city'),
            subtitle: Text('${fromName ?? from} (locked)'),
          ),
          dropdown(
            'To city',
            field('to_city').text,
            [
              for (final city in cities.where((e) => expenseId(e) != from))
                MapEntry(expenseId(city), '${city['name']}'),
            ],
            (v) => setState(() => field('to_city').text = v),
            errorKey: 'details.to_city',
          ),
          text('rate_per_kg', 'Rate per kg (₹)', decimals: 2),
          text('weight_kg', 'Weight (kg)', decimals: 3),
          text('reference_no', 'AWB / challan (optional)', required: false),
        ];
      case 'MISC':
        return [
          dropdown(
            'Expense head',
            head,
            [
              for (final e in expenseMaps(c.meta['expense_heads']))
                MapEntry(expenseId(e), '${e['name']}'),
              const MapEntry('other', 'Other'),
            ],
            (v) => setState(() => head = v),
            errorKey: 'details.expense_head',
          ),
          if (head == 'other')
            text('head_other', 'Other expense head', maxLength: 100),
          text('description', 'Details', lines: 2),
          text('reason', 'Reason', lines: 2),
          text('amount', 'Amount (₹)', decimals: 2),
        ];
      case 'PETROL':
        return [
          text('rate_per_litre', 'Rate per litre (₹)', decimals: 2),
          text('litres', 'Litres', decimals: 2),
          text('start_km', 'Start odometer (km)', decimals: 1, zero: true),
          dateInput(
            'Filling date (optional)',
            field('filled_at').text,
            (v) => field('filled_at').text = v,
          ),
          text('vehicle_no', 'Vehicle number (optional)', required: false),
          text('pump_name', 'Petrol pump (optional)', required: false),
        ];
      case 'TRAVEL':
        return [
          text('from_place', 'From'),
          text('to_place', 'To'),
          dropdown(
            'Travel mode',
            mode,
            [
              for (final e in expenseMaps(c.meta['travel_modes']))
                MapEntry('${e['value']}', '${e['label']}'),
            ],
            (v) => setState(() => mode = v),
            errorKey: 'details.travel_mode',
          ),
          if (mode == 'other')
            text('travel_mode_other', 'Mode name', maxLength: 100),
          dateInput(
            'Journey date (optional)',
            field('journey_date').text,
            (v) => field('journey_date').text = v,
          ),
          text('purpose', 'Purpose (optional)', required: false),
          text('amount', 'Amount (₹)', decimals: 2),
        ];
      case 'DELIVERY':
        final selected = orders.where((e) => expenseId(e) == order).firstOrNull;
        final sides = (selected?['sides'] as List? ?? [])
            .map((e) => '$e')
            .toList();
        return [
          ...orderSearch(),
          dropdown(
            'Order',
            order,
            [
              for (final e in orders)
                MapEntry(expenseId(e), '${e['orderid'] ?? expenseId(e)}'),
            ],
            selectOrder,
            errorKey: 'details.order',
            requiredForDraft: true,
            optionWidgets: {
              for (final e in orders)
                expenseId(e): Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('${e['orderid'] ?? expenseId(e)}'),
                      ExpenseOrderInfo(order: e, purchase: false),
                    ],
                  ),
                ),
            },
          ),
          if (sides.length > 1)
            dropdown(
              'Side',
              side,
              [for (final s in sides) MapEntry(s, s)],
              (v) async {
                setState(() {
                  side = v;
                  distance = null;
                  loading = true;
                });
                try {
                  if (!await openDeliveryExpense()) await loadDistance();
                } catch (e) {
                  error = '$e';
                } finally {
                  if (mounted) setState(() => loading = false);
                }
              },
              errorKey: 'details.side',
              requiredForDraft: true,
            ),
          if (selected != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: ExpenseOrderInfo(order: selected, purchase: false),
            ),
          if (distance != null)
            Material(
              color: Colors.transparent,
              child: ListTile(
                title: Text(
                  'Default distance: ${distance!['km'] == null ? 'Not available' : '${distance!['km']} km'}',
                ),
                subtitle: Text(
                  '${distance!['message'] ?? distance!['source'] ?? ''}',
                ),
              ),
            ),
          text(
            'actual_distance_km',
            'Actual distance (km)',
            decimals: 2,
            zero: true,
          ),
          const Text(
            'Delivery amount is currently ₹0.00, as defined by the server.',
          ),
        ];
      case 'FOOD_PURCHASE':
        return [
          Text('Estimated total: ${expenseMoney(foodPreviewPaise())}'),
          const Text('Final totals are calculated by the server.'),
          ExpenseOrderDropdown(
            orders: orders,
            currentExpenseId: currentExpense?.expense.id,
            onOpenExpense: openExistingExpense,
            selected: selectedOrders,
            enabled: !loading && !saving,
            errorText: serverErrors['details.orders'],
            onSearch: (query) async {
              lookupQuery = query;
              await findOrders();
              if (mounted) setState(() {});
            },
            onApply: (selection) async {
              if (selection.length == selectedOrders.length &&
                  selection.containsAll(selectedOrders)) {
                return;
              }
              setState(() {
                selectedOrders = selection;
                for (final id in selection) {
                  if (!orders.any((o) => expenseId(o) == id) &&
                      orderCatalog[id] != null) {
                    orders.add(orderCatalog[id]!);
                  }
                }
                ordersChanged = true;
              });
              if (selection.isEmpty) {
                setState(() => lines = []);
              } else {
                await foodLines();
              }
            },
          ),
          const SizedBox(height: 10),
          const Text(
            'Select up to 50 orders from the same city.',
            style: TextStyle(fontSize: 12, color: muted),
          ),
          if (selectedOrders.isNotEmpty) ...[
            const SizedBox(height: 12),
            Column(
              children: [
                for (final id in selectedOrders)
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(
                      '${orders.where((o) => expenseId(o) == id).firstOrNull?['orderid'] ?? id}',
                      style: const TextStyle(
                        fontFamily: 'Roboto',
                        color: accent,
                        fontSize: 11,
                      ),
                    ),
                    subtitle: ExpenseOrderInfo(
                      order:
                          orders.where((o) => expenseId(o) == id).firstOrNull ??
                          {},
                      purchase: true,
                    ),
                  ),
              ],
            ),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: loading ? null : foodLines,
                icon: const Icon(Icons.refresh_rounded, size: 16),
                label: const Text('Refresh product lines'),
              ),
            ),
          ],
          const SizedBox(height: 12),
          for (int i = 0; i < lines.length; i++) foodLine(i),
        ];
      case 'CANCELLED_ORDER':
        return [
          ...orderSearch(),
          dropdown(
            'Cancelled order',
            order,
            [
              for (final e in orders)
                MapEntry(
                  expenseId(e),
                  '${e['orderid']} • ${e['stage_label'] ?? e['status_label'] ?? ''}',
                ),
            ],
            selectOrder,
            errorKey: 'details.order',
            requiredForDraft: true,
          ),
          text(
            'cancel_reason',
            'Cancellation details (optional)',
            required: false,
            maxLength: 500,
          ),
          for (int i = 0; i < lines.length; i++) cancelledLine(i),
          const Text(
            'Save a draft, then approve when complete. This records food usage and does not affect cash.',
          ),
        ];
      default:
        return [
          const Text('This expense type is not supported by this app version.'),
        ];
    }
  }

  List<Widget> orderSearch() => [
    TextFormField(
      initialValue: lookupQuery,
      decoration: InputDecoration(
        labelText: 'Find order by number',
        suffixIcon: IconButton(
          icon: const Icon(Icons.search),
          onPressed: searchOrders,
        ),
      ),
      onChanged: (v) => lookupQuery = v.trim(),
      onFieldSubmitted: (_) => searchOrders(),
    ),
    const SizedBox(height: 12),
  ];
  Future<void> searchOrders() async {
    setState(() {
      loading = true;
      error = '';
    });
    try {
      await findOrders();
    } catch (e) {
      error = '$e';
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  Widget lineNumber(
    Map<String, dynamic> line,
    String key,
    String label,
    String path, {
    int decimals = 2,
    bool required = true,
    bool zero = false,
    VoidCallback? changed,
  }) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: TextFormField(
      key: ValueKey('$path:$key:${expenseId(line['product'])}'),
      initialValue: '${line[key] ?? ''}',
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      decoration: InputDecoration(
        labelText: label,
        errorText: serverErrors['$path.$key'],
      ),
      onChanged: (v) {
        setState(() {
          line[key] = v;
          serverErrors.remove('$path.$key');
        });
        changed?.call();
      },
      validator: (v) =>
          validateNumber(v, decimals, required: required, zero: zero),
    ),
  );
  num finalQuantity(Map<String, dynamic> line) =>
      expenseNumber(line['order_quantity']) +
      expenseMaps(line['adjustments'])
          .fold<num>(0, (sum, e) => sum + expenseNumber(e['quantity']));
  Widget foodLine(int i) {
    final line = lines[i], path = 'details.items[$i]';
    final adjustments = expenseMaps(line['adjustments']);
    final finalQty = finalQuantity(line);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${line['product_name'] ?? expenseId(line['product'])}',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            Text('${expenseMap(line['vendor'])['name'] ?? ''}'),
            Text(
              expenseMaps(line['orders'])
                  .map((o) => '${o['orderid']} × ${o['quantity']}')
                  .join(', '),
            ),
            Text(
              'Order quantity: ${line['order_quantity']} • Final quantity: $finalQty',
            ),
            for (final entry in serverErrors.entries.where(
              (e) => e.key.startsWith('$path.adjustments['),
            ))
              Text(
                entry.value,
                style: const TextStyle(fontFamily: 'Roboto', color: Colors.red),
              ),
            if (serverErrors['$path.adjustments'] != null)
              Text(
                serverErrors['$path.adjustments']!,
                style: const TextStyle(fontFamily: 'Roboto', color: Colors.red),
              ),
            for (int j = 0; j < adjustments.length; j++)
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(
                  '${adjustments[j]['quantity']} • ${adjustments[j]['note']}',
                ),
                subtitle: Text('${adjustments[j]['orderid'] ?? ''}'),
                trailing: IconButton(
                  icon: const Icon(Icons.delete_outline),
                  onPressed: () => setState(() {
                    adjustments.removeAt(j);
                    line['adjustments'] = adjustments;
                  }),
                ),
              ),
            if (adjustments.length < 20)
              TextButton(
                onPressed: () => addAdjustment(i),
                child: const Text('Change quantity'),
              ),
            lineNumber(
              line,
              'rate',
              'Rate per unit (₹)',
              path,
              required: finalQty > 0,
              zero: finalQty == 0,
            ),
            lineNumber(
              line,
              'weight_kg',
              'Total weight (kg), optional',
              path,
              decimals: 3,
              required: false,
              zero: true,
            ),
            Text(
              'Unit rate ${expenseMoney(expenseNumber(line['rate']) * 100)} x $finalQty = ${expenseMoney(expenseNumber(line['rate']) * finalQty * 100)}',
              key: ValueKey('$path.product-cost'),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<bool>(
              key: ValueKey('$path.gst:$gstApplicable'),
              initialValue: gstApplicable,
              decoration: const InputDecoration(
                labelText: 'GST (all products)',
              ),
              items: const [
                DropdownMenuItem(value: true, child: Text('Yes (5%)')),
                DropdownMenuItem(value: false, child: Text('No')),
              ],
              onChanged: saving || loading
                  ? null
                  : (value) {
                      if (value != null) setState(() => gstApplicable = value);
                    },
            ),
            const SizedBox(height: 8),
            Text('GST: ${expenseMoney(foodLineTaxPaise(line))}'),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              key: ValueKey('$path.discount:${line['discount_type']}'),
              initialValue: '${line['discount_type'] ?? 'amount'}',
              decoration: const InputDecoration(labelText: 'Discount type'),
              items: const [
                DropdownMenuItem(value: 'amount', child: Text('Amount (₹)')),
                DropdownMenuItem(value: 'percent', child: Text('Percent (%)')),
              ],
              onChanged: (v) => setState(() => line['discount_type'] = v),
            ),
            const SizedBox(height: 12),
            lineNumber(
              line,
              'discount_value',
              'Discount (optional)',
              path,
              required: false,
              zero: true,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> addAdjustment(int i) async {
    validatingSubmit = false;
    final line = lines[i];
    final quantity = TextEditingController(),
        note = TextEditingController(),
        orderNumber = TextEditingController();
    final key = GlobalKey<FormState>();
    bool add = true;
    final accepted = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, set) => AlertDialog(
          title: const Text('Change quantity'),
          content: SingleChildScrollView(
            child: Form(
              key: key,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButtonFormField<bool>(
                    initialValue: true,
                    items: const [
                      DropdownMenuItem(value: true, child: Text('Add')),
                      DropdownMenuItem(value: false, child: Text('Less')),
                    ],
                    onChanged: (v) => set(() => add = v ?? true),
                  ),
                  TextFormField(
                    controller: quantity,
                    decoration: const InputDecoration(labelText: 'Quantity'),
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    validator: (v) {
                      final error = validateNumber(v, 3);
                      if (error != null) return error;
                      return !add && finalQuantity(line) - expenseNumber(v) < 0
                          ? 'Final quantity cannot be negative'
                          : null;
                    },
                  ),
                  TextFormField(
                    controller: orderNumber,
                    decoration: const InputDecoration(
                      labelText: 'Order number (optional)',
                    ),
                  ),
                  TextFormField(
                    controller: note,
                    maxLength: 1000,
                    decoration: const InputDecoration(labelText: 'Reason'),
                    validator: (v) =>
                        (v ?? '').trim().isNotEmpty &&
                            (v ?? '').trim().length < 3
                        ? 'Enter at least 3 characters'
                        : null,
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                if (key.currentState!.validate()) Navigator.pop(context, true);
              },
              child: const Text('Add'),
            ),
          ],
        ),
      ),
    );
    if (accepted == true && mounted) {
      setState(
        () => line['adjustments'] = [
          ...expenseMaps(line['adjustments']),
          {
            'quantity': quantity.text.trim().isEmpty
                ? ''
                : '${add ? '+' : '-'}${quantity.text.trim()}',
            'note': note.text.trim(),
            if (orderNumber.text.trim().isNotEmpty)
              'orderid': orderNumber.text.trim(),
          },
        ],
      );
    }
    // Dialog text controllers are disposed after its reverse animation.
    await Future<void>.delayed(const Duration(milliseconds: 250));
    quantity.dispose();
    note.dispose();
    orderNumber.dispose();
  }

  Widget cancelledLine(int i) {
    final line = lines[i];
    final entries = expenseMaps(line['dispositions']);
    final left =
        expenseNumber(line['quantity']) -
        entries.fold<num>(0, (sum, e) => sum + expenseNumber(e['quantity']));
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${line['product_name'] ?? expenseId(line['product'])}',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            Text('Quantity: ${line['quantity']} • Left: $left'),
            for (int j = 0; j < entries.length; j++)
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(
                  '${entries[j]['type']} • ${entries[j]['quantity']}',
                ),
                subtitle: Text(
                  '${expenseDay(entries[j]['date'])} ${entries[j]['orderid'] ?? ''} ${entries[j]['note'] ?? ''}',
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.delete_outline),
                  onPressed: () => setState(() {
                    entries.removeAt(j);
                    line['dispositions'] = entries;
                  }),
                ),
              ),
            if (entries.length < 30 && left > 0)
              TextButton(
                onPressed: () => addDisposition(i, left),
                child: const Text('Add food usage'),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> addDisposition(int i, num left) async {
    final entry = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => FoodUsageDialog(
        available: left,
        allowIncomplete: true,
        backdateDays: expenseNumber(c.meta['backdate_days'] ?? 7).toInt(),
        productName: '${lines[i]['product_name'] ?? ''}',
      ),
    );
    if (entry != null && mounted) {
      setState(
        () => lines[i]['dispositions'] = [
          ...expenseMaps(lines[i]['dispositions']),
          entry,
        ],
      );
    }
  }

  Map<String, dynamic> payloadDetails() {
    Map<String, dynamic> values(List<String> names) => {
      for (final name in names)
        if (field(name).text.trim().isNotEmpty) name: field(name).text.trim(),
    };
    switch (category) {
      case 'INTERCITY_LOGISTICS':
        return values([
          'from_city',
          'to_city',
          'rate_per_kg',
          'weight_kg',
          'reference_no',
        ]);
      case 'MISC':
        return {
          ...values(['description', 'reason', 'amount']),
          if (head == 'other')
            'head_other': field('head_other').text.trim()
          else
            'expense_head': head,
        };
      case 'PETROL':
        return values([
          'rate_per_litre',
          'litres',
          'start_km',
          'filled_at',
          'vehicle_no',
          'pump_name',
        ]);
      case 'TRAVEL':
        return {
          ...values([
            'from_place',
            'to_place',
            'journey_date',
            'purpose',
            'amount',
          ]),
          'travel_mode': mode,
          if (mode == 'other')
            'travel_mode_other': field('travel_mode_other').text.trim(),
        };
      case 'DELIVERY':
        return {
          ...values(['actual_distance_km']),
          'order': order,
          if (side.isNotEmpty) 'side': side,
        };
      case 'FOOD_PURCHASE':
        final foodItems = <Map<String, dynamic>>[];
        for (final line in lines) {
          final item = <String, dynamic>{'product': expenseId(line['product'])};
          for (final key in [
            'rate',
            'weight_kg',
            'discount_type',
            'discount_value',
          ]) {
            if ('${line[key] ?? ''}'.isNotEmpty) item[key] = line[key];
          }
          item['adjustments'] = expenseMaps(line['adjustments'])
              .map(
                (a) => {
                  'quantity': '${a['quantity'] ?? ''}',
                  'note': a['note'],
                  if ('${a['orderid'] ?? ''}'.isNotEmpty)
                    'orderid': a['orderid'],
                },
              )
              .toList();
          foodItems.add(item);
        }
        return {
          if (!editing || ordersChanged) 'orders': selectedOrders.toList(),
          'items': foodItems,
          'gst_applicable': gstApplicable,
          if (gstApplicable) 'gst_percent': '5',
        };
      case 'CANCELLED_ORDER':
        final items = <Map<String, dynamic>>[];
        for (final line in lines) {
          final dispositions = <Map<String, dynamic>>[];
          for (final disposition in expenseMaps(line['dispositions'])) {
            dispositions.add({
              'type': disposition['type'],
              'quantity': '${disposition['quantity'] ?? ''}',
              if (disposition['date'] != null)
                'date': expenseDay(disposition['date']),
              if (disposition['orderid'] != null)
                'orderid': disposition['orderid'],
              if (disposition['note'] != null) 'note': disposition['note'],
            });
          }
          items.add({
            'line_id': expenseId(line['line_id']),
            'dispositions': dispositions,
          });
        }
        return {
          'order': order,
          ...values(['cancel_reason']),
          'items': items,
        };
      default:
        throw ExpenseApiException(null, 'Unsupported expense type');
    }
  }

  Future<void> save(bool submit) async {
    if (saving) return;
    validatingSubmit = submit;
    if (!form.currentState!.validate()) return;
    if (category == 'FOOD_PURCHASE' &&
        (selectedOrders.isEmpty || lines.isEmpty)) {
      setState(() => error = 'Select orders and load product lines first.');
      return;
    }
    if (category == 'CANCELLED_ORDER' && (order.isEmpty || lines.isEmpty)) {
      setState(() => error = 'Select a cancelled order first.');
      return;
    }
    // Changing the order checkboxes requires refreshing the server's combined lines.
    if (category == 'FOOD_PURCHASE' && lines.isNotEmpty) {
      final lineOrders = lines
          .expand(
            (e) => expenseMaps(e['orders']).map((o) => expenseId(o['order'])),
          )
          .toSet();
      if (lineOrders.isNotEmpty &&
          (lineOrders.length != selectedOrders.length ||
              !lineOrders.containsAll(selectedOrders))) {
        setState(
          () => error = 'Load / update product lines after changing orders.',
        );
        return;
      }
    }
    setState(() {
      saving = true;
      error = '';
      serverErrors = {};
    });
    try {
      final response = await c.save({
        if (!editing) 'category': category,
        if (!editing || date != currentExpense!.expense.date)
          'expense_date': date,
        'notes': field('notes').text.trim(),
        'details': payloadDetails(),
        if (!editing) 'client_request_id': requestId,
        if (!editing && category != 'CANCELLED_ORDER') 'submit': submit,
        if (editing && currentExpense!.expense.version != null)
          'version': currentExpense!.expense.version,
      }, id: currentExpense?.expense.id);
      if (!mounted) return;
      if (response != null) {
        if (editing) {
          Get.back(result: true);
        } else {
          Get.off(() => ExpenseDetailScreen(id: response.expense.id));
        }
        c.getExpenseList();
        c.loadLedger().catchError((Object e) => c.showError(e));
      } else {
        setState(() {
          error = c.error;
          serverErrors = Map.of(c.fieldErrors);
        });
        if (editing && c.lastStatusCode == 409) {
          final fresh = await c.getDetail(currentExpense!.expense.id);
          if (!mounted) return;
          if (!fresh.can('edit')) {
            Get.back(result: true);
            return;
          }
          currentExpense = fresh;
          for (final controller in fields.values) {
            controller.clear();
          }
          lines = [];
          selectedOrders = {};
          serverErrors = {};
          ordersChanged = false;
          await initialize();
          if (mounted) {
            setState(
              () => error = 'This expense changed. Fresh details have been loaded; review before saving.',
            );
          }
        } else if (editing && c.lastStatusCode == 404) {
          await c.refreshAfterDeletion();
          if (mounted) Get.back(result: true);
        }
      }
    } catch (e) {
      if (mounted) setState(() => error = '$e');
    } finally {
      if (mounted) setState(() => saving = false);
    }
  }
}
