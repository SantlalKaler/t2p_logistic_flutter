import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../domain/Model/expense/expense_v1.dart';
import 'add_edit_expense_screen.dart';
import 'components/expense_design.dart';
import 'expense_controller.dart';
import 'single_cod_expense.dart';
import 'expense_ledger.dart';

class ExpenseListScreen extends StatefulWidget {
  const ExpenseListScreen({super.key});
  @override
  State<ExpenseListScreen> createState() => _ExpenseListScreenState();
}

class _ExpenseListScreenState extends State<ExpenseListScreen> {
  final ExpenseController controller = Get.find();
  final search = TextEditingController();
  @override
  void initState() {
    super.initState();
    search.text = controller.search;
    controller.initialize();
  }

  @override
  void dispose() {
    search.dispose();
    super.dispose();
  }

  void searchExpenses() {
    controller.search = search.text.trim();
    controller.getExpenseList();
  }

  bool get filtered =>
      controller.category.isNotEmpty ||
      controller.from.isNotEmpty ||
      controller.to.isNotEmpty;
  String categoryLabel(List<Map<String, dynamic>> categories, String code) =>
      '${categories.where((e) => e['code'] == code).firstOrNull?['label'] ?? code}';

  @override
  Widget build(BuildContext context) => Theme(
    data: ExpenseDesign.theme(context),
    child: Builder(
      builder: (context) => GetBuilder<ExpenseController>(
        builder: (c) {
          final statuses =
              (c.meta['statuses'] as List?)?.cast<String>() ??
              ['draft', 'submitted', 'approved', 'rejected', 'cancelled'];
          final categories = expenseMaps(c.meta['categories']);
          final balance = expenseMap(c.ledger['account'])['balance'];
          final canAdd =
              expenseMap(
                expenseMap(c.meta['permissions'])['expense'],
              )['add_edit'] ==
              true;
          final filterCount =
              (c.category.isNotEmpty ? 1 : 0) +
              (c.from.isNotEmpty || c.to.isNotEmpty ? 1 : 0);
          return Scaffold(
            appBar: AppBar(
              title: const Text('Expenses'),
              leading: IconButton(
                tooltip: 'Back',
                onPressed: () => Get.back(),
                icon: const Icon(Icons.arrow_back_rounded),
              ),
              actions: [
                IconButton(
                  tooltip: 'Refresh',
                  onPressed: c.isLoading ? null : c.initialize,
                  icon: const Icon(Icons.refresh_rounded),
                ),
              ],
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(1),
                child: Container(height: 1, color: const Color(0xFFEAECF0)),
              ),
            ),
            floatingActionButton: canAdd
                ? FloatingActionButton.extended(
                    onPressed: () => Get.to(() => const AddEditExpenseScreen()),
                    backgroundColor: ExpenseDesign.accent,
                    foregroundColor: Colors.white,
                    elevation: 3,
                    icon: const Icon(Icons.add_rounded),
                    label: const Text(
                      'New expense',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  )
                : null,
            body: SafeArea(
              top: false,
              child: RefreshIndicator(
                onRefresh: c.initialize,
                child: CustomScrollView(
                  keyboardDismissBehavior:
                      ScrollViewKeyboardDismissBehavior.onDrag,
                  physics: const AlwaysScrollableScrollPhysics(),
                  slivers: [
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
                      sliver: SliverList.list(
                        children: [
                          cashCard(context, balance),
                          const SizedBox(height: 20),
                          Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: search,
                                  textInputAction: TextInputAction.search,
                                  style: const TextStyle(fontSize: 13),
                                  onChanged: (_) => setState(() {}),
                                  decoration: InputDecoration(
                                    hintText: 'Search expense or order',
                                    prefixIcon: IconButton(
                                      tooltip: 'Search',
                                      onPressed: searchExpenses,
                                      icon: const Icon(
                                        Icons.search_rounded,
                                        size: 21,
                                      ),
                                    ),
                                    fillColor: Colors.white,
                                    suffixIcon: search.text.isEmpty
                                        ? null
                                        : IconButton(
                                            tooltip: 'Clear search',
                                            onPressed: () {
                                              search.clear();
                                              searchExpenses();
                                            },
                                            icon: const Icon(
                                              Icons.close_rounded,
                                              size: 18,
                                            ),
                                          ),
                                  ),
                                  onSubmitted: (_) => searchExpenses(),
                                ),
                              ),
                              const SizedBox(width: 10),
                              SizedBox(
                                width: 52,
                                height: 52,
                                child: Badge(
                                  isLabelVisible: filterCount > 0,
                                  label: Text('$filterCount'),
                                  backgroundColor: ExpenseDesign.accent,
                                  child: OutlinedButton(
                                    style: OutlinedButton.styleFrom(
                                      padding: EdgeInsets.zero,
                                      backgroundColor: Colors.white,
                                    ),
                                    onPressed: c.isLoading
                                        ? null
                                        : () => filters(context, c, categories),
                                    child: const Icon(
                                      Icons.tune_rounded,
                                      size: 22,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          if (filtered)
                            Padding(
                              padding: const EdgeInsets.only(top: 10),
                              child: Wrap(
                                spacing: 6,
                                runSpacing: 6,
                                children: [
                                  if (c.category.isNotEmpty)
                                    filterChip(
                                      categoryLabel(categories, c.category),
                                      () {
                                        c.category = '';
                                        c.getExpenseList();
                                      },
                                    ),
                                  if (c.from.isNotEmpty || c.to.isNotEmpty)
                                    filterChip(
                                      '${c.from.isEmpty ? 'Any date' : c.from} – ${c.to.isEmpty ? 'Today' : c.to}',
                                      () {
                                        c.from = '';
                                        c.to = '';
                                        c.getExpenseList();
                                      },
                                    ),
                                  TextButton(
                                    onPressed: () {
                                      c.category = '';
                                      c.from = '';
                                      c.to = '';
                                      c.getExpenseList();
                                    },
                                    child: const Text('Clear all'),
                                  ),
                                ],
                              ),
                            ),
                          const SizedBox(height: 18),
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: [
                                for (final status in ['', ...statuses])
                                  Padding(
                                    padding: const EdgeInsets.only(right: 8),
                                    child: ChoiceChip(
                                      showCheckmark: false,
                                      selected: c.status == status,
                                      backgroundColor: Colors.white,
                                      selectedColor: ExpenseDesign.accent,
                                      side: BorderSide(
                                        color: c.status == status
                                            ? ExpenseDesign.accent
                                            : const Color(0xFFE4E7EC),
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      labelStyle: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                        color: c.status == status
                                            ? Colors.white
                                            : ExpenseDesign.muted,
                                      ),
                                      label: Text(
                                        status.isEmpty
                                            ? 'All'
                                            : '${expenseStatusLabel(status)} ${expenseMap(expenseMap(c.totals['by_status'])[status])['count'] ?? 0}',
                                      ),
                                      onSelected: c.isLoading
                                          ? null
                                          : (_) {
                                              c.status = status;
                                              c.getExpenseList();
                                            },
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),
                          Row(
                            children: [
                              const Expanded(
                                child: Text(
                                  'My expenses',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                              if (c.totals['count'] != null)
                                Text(
                                  '${c.totals['count']} records',
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                            ],
                          ),
                          if (c.totals['amount'] != null)
                            Padding(
                              padding: const EdgeInsets.only(top: 3),
                              child: Text(
                                'Total ${expenseMoney(c.totals['amount'])}',
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ),
                          const SizedBox(height: 14),
                          if (c.isLoading)
                            const Padding(
                              padding: EdgeInsets.only(bottom: 14),
                              child: LinearProgressIndicator(minHeight: 3),
                            ),
                        ],
                      ),
                    ),
                    if (c.error.isNotEmpty)
                      SliverFillRemaining(
                        hasScrollBody: false,
                        child: emptyState(
                          context,
                          icon: Icons.cloud_off_outlined,
                          title: 'Could not load expenses',
                          message: c.error,
                          action: TextButton(
                            onPressed: c.initialize,
                            child: const Text('Try again'),
                          ),
                        ),
                      )
                    else if (c.expenses.isEmpty && !c.isLoading)
                      SliverFillRemaining(
                        hasScrollBody: false,
                        child: emptyState(
                          context,
                          icon: Icons.receipt_long_outlined,
                          title: 'No expenses found',
                          message:
                              filtered ||
                                  c.search.isNotEmpty ||
                                  c.status.isNotEmpty
                              ? 'Try another search or change your filters.'
                              : 'Your expenses will appear here once you add them.',
                        ),
                      )
                    else
                      SliverPadding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        sliver: SliverList.builder(
                          itemCount: c.expenses.length,
                          itemBuilder: (context, i) =>
                              SingleExpenseItem(expense: c.expenses[i]),
                        ),
                      ),
                    if (c.pages > 1)
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              IconButton(
                                tooltip: 'Previous page',
                                onPressed: c.page > 1 && !c.isLoading
                                    ? () =>
                                          c.getExpenseList(nextPage: c.page - 1)
                                    : null,
                                icon: const Icon(Icons.chevron_left_rounded),
                              ),
                              Text(
                                'Page ${c.page} of ${c.pages}',
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                              IconButton(
                                tooltip: 'Next page',
                                onPressed: c.page < c.pages && !c.isLoading
                                    ? () =>
                                          c.getExpenseList(nextPage: c.page + 1)
                                    : null,
                                icon: const Icon(Icons.chevron_right_rounded),
                              ),
                            ],
                          ),
                        ),
                      ),
                    SliverToBoxAdapter(
                      child: SizedBox(height: canAdd ? 96 : 24),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    ),
  );

  Widget cashCard(BuildContext context, dynamic balance) => Material(
    color: Colors.white,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(18),
      side: const BorderSide(color: Color(0xFFEAECF0)),
    ),
    clipBehavior: Clip.antiAlias,
    child: InkWell(
      onTap: () => Get.to(() => const ExpenseLedgerScreen()),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(9),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFDF0F1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.account_balance_wallet_outlined,
                    size: 20,
                    color: ExpenseDesign.accent,
                  ),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'Cash in hand',
                    style: TextStyle(
                      fontSize: 13,
                      color: ExpenseDesign.muted,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const Icon(
                  Icons.arrow_forward_rounded,
                  size: 18,
                  color: ExpenseDesign.muted,
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              balance == null ? 'Balance unavailable' : expenseMoney(balance),
              style: TextStyle(
                fontSize: balance == null ? 18 : 29,
                fontWeight: FontWeight.w700,
                color: expenseNumber(balance) < 0
                    ? ExpenseDesign.accent
                    : ExpenseDesign.ink,
                letterSpacing: -.5,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Expanded(
                  child: Text(
                    expenseNumber(balance) < 0
                        ? 'You have spent more than received.'
                        : 'Your current available balance',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
                const SizedBox(width: 8),
                const Text(
                  'View ledger',
                  style: TextStyle(
                    fontSize: 11,
                    color: ExpenseDesign.accent,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  );
  Widget filterChip(String label, VoidCallback remove) => InputChip(
    label: Text(label, style: const TextStyle(fontSize: 11)),
    onDeleted: remove,
    deleteIcon: const Icon(Icons.close_rounded, size: 15),
    backgroundColor: const Color(0xFFFDF0F1),
    side: BorderSide.none,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
  );
  Widget emptyState(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String message,
    Widget? action,
  }) => Padding(
    padding: const EdgeInsets.fromLTRB(28, 24, 28, 72),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(18),
          decoration: const BoxDecoration(
            color: Color(0xFFEAECF0),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 30, color: const Color(0xFF98A2B3)),
        ),
        const SizedBox(height: 16),
        Text(
          title,
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 6),
        Text(
          message,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodySmall,
        ),
        ?action,
      ],
    ),
  );

  Future<void> filters(
    BuildContext context,
    ExpenseController c,
    List<Map<String, dynamic>> categories,
  ) async {
    String category = c.category, from = c.from, to = c.to;
    final apply = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, set) {
          final valid = from.isEmpty || to.isEmpty || from.compareTo(to) <= 0;
          Future<void> pick(bool first) async {
            final current = first ? from : to;
            final date = await showDatePicker(
              context: context,
              initialDate: DateTime.tryParse(current) ?? DateTime.now(),
              firstDate: DateTime(2020),
              lastDate: DateTime.now(),
            );
            if (date != null && context.mounted) {
              set(() {
                if (first) {
                  from = expenseDay(date);
                } else {
                  to = expenseDay(date);
                }
              });
            }
          }

          Widget dateField(bool first) => InkWell(
            onTap: () => pick(first),
            borderRadius: BorderRadius.circular(12),
            child: InputDecorator(
              decoration: InputDecoration(
                labelText: first ? 'From date' : 'To date',
                suffixIcon: const Icon(Icons.calendar_today_outlined, size: 18),
              ),
              child: Text(
                (first ? from : to).isEmpty ? 'Any date' : (first ? from : to),
                style: const TextStyle(fontSize: 12),
              ),
            ),
          );
          return Padding(
            padding: EdgeInsets.fromLTRB(
              20,
              12,
              20,
              MediaQuery.viewInsetsOf(context).bottom + 16,
            ),
            child: SafeArea(
              top: false,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: Container(
                      width: 36,
                      height: 4,
                      decoration: BoxDecoration(
                        color: const Color(0xFFD0D5DD),
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      const Expanded(
                        child: Text(
                          'Filter expenses',
                          style: TextStyle(
                            fontSize: 19,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      IconButton(
                        tooltip: 'Close filters',
                        onPressed: () => Navigator.pop(context, false),
                        icon: const Icon(Icons.close_rounded, size: 21),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    key: ValueKey(category),
                    initialValue: category,
                    isExpanded: true,
                    decoration: const InputDecoration(labelText: 'Category'),
                    items: [
                      const DropdownMenuItem(
                        value: '',
                        child: Text('All categories'),
                      ),
                      for (final item in categories)
                        DropdownMenuItem(
                          value: '${item['code']}',
                          child: Text(
                            '${item['label']}',
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                    ],
                    onChanged: (v) => set(() => category = v ?? ''),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(child: dateField(true)),
                      const SizedBox(width: 12),
                      Expanded(child: dateField(false)),
                    ],
                  ),
                  if (!valid)
                    const Padding(
                      padding: EdgeInsets.only(top: 10),
                      child: Text(
                        'From date must be before To date',
                        style: TextStyle(fontSize: 12, color: Colors.red),
                      ),
                    ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => set(() {
                            category = '';
                            from = '';
                            to = '';
                          }),
                          child: const Text('Reset'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: FilledButton(
                          onPressed: valid
                              ? () => Navigator.pop(context, true)
                              : null,
                          child: const Text('Apply filters'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
    if (apply == true) {
      c.category = category;
      c.from = from;
      c.to = to;
      await c.getExpenseList();
    }
  }
}
