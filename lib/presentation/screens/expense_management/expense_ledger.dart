import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../domain/Model/expense/expense_v1.dart';
import 'components/expense_design.dart';
import 'expense_controller.dart';
import 'expense_detail.dart';

class ExpenseLedgerScreen extends StatefulWidget {
  const ExpenseLedgerScreen({super.key});
  @override
  State<ExpenseLedgerScreen> createState() => _ExpenseLedgerScreenState();
}

class _ExpenseLedgerScreenState extends State<ExpenseLedgerScreen> {
  final ExpenseController c = Get.find();
  Map<String, dynamic> ledger = {};
  String from = '', to = '', type = '', error = '';
  bool loading = false;
  int page = 1;
  bool get filtered => from.isNotEmpty || to.isNotEmpty || type.isNotEmpty;
  String get period => from.isEmpty && to.isEmpty
      ? 'All time'
      : '${from.isEmpty ? 'Any date' : from} – ${to.isEmpty ? 'Today' : to}';
  @override
  void initState() {
    super.initState();
    load();
  }

  Future<void> load({int nextPage = 1}) async {
    setState(() {
      loading = true;
      error = '';
    });
    try {
      await c.loadLedger(nextPage: nextPage, from: from, to: to, type: type);
      if (mounted) {
        setState(() {
          ledger = Map.of(c.ledger);
          page = nextPage;
        });
      }
    } catch (e) {
      if (mounted) setState(() => error = '$e');
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  String amount(dynamic value) => value == null ? '—' : expenseMoney(value);

  @override
  Widget build(BuildContext context) => Theme(
    data: ExpenseDesign.theme(context),
    child: Builder(
      builder: (context) {
        final summary = expenseMap(ledger['summary']);
        final balance = expenseMap(ledger['account'])['balance'];
        final types = expenseMap(c.meta['ledger_types']);
        final pagination = expenseMap(ledger['pagination']);
        final entries = expenseMaps(ledger['entries']);
        return Scaffold(
          appBar: AppBar(
            title: const Text('My cash'),
            leading: IconButton(
              tooltip: 'Back',
              onPressed: () => Get.back(),
              icon: const Icon(Icons.arrow_back_rounded),
            ),
            actions: [
              IconButton(
                tooltip: 'Refresh',
                onPressed: loading ? null : load,
                icon: const Icon(Icons.refresh_rounded),
              ),
            ],
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(1),
              child: Container(height: 1, color: const Color(0xFFEAECF0)),
            ),
          ),
          body: SafeArea(
            top: false,
            child: RefreshIndicator(
              onRefresh: load,
              child: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
                    sliver: SliverList.list(
                      children: [
                        balanceCard(context, balance),
                        const SizedBox(height: 22),
                        Row(
                          children: [
                            const Expanded(
                              child: Text(
                                'Period summary',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                            Text(
                              period == 'All time' ? period : 'Custom period',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                        if (period != 'All time')
                          Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text(
                              period,
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: summaryCard(
                                context,
                                'Opening balance',
                                summary['opening_balance'],
                                Icons.account_balance_wallet_outlined,
                                ExpenseDesign.muted,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: summaryCard(
                                context,
                                'Received from HO',
                                summary['received_from_head_office'],
                                Icons.south_west_rounded,
                                const Color(0xFF067647),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: summaryCard(
                                context,
                                'Expenses deducted',
                                summary['expenses_deducted'],
                                Icons.north_east_rounded,
                                ExpenseDesign.accent,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: summaryCard(
                                context,
                                'Closing balance',
                                summary['closing_balance'],
                                Icons.payments_outlined,
                                ExpenseDesign.ink,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 22),
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Transactions',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  Text(
                                    '${pagination['total'] ?? entries.length} entries',
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodySmall,
                                  ),
                                ],
                              ),
                            ),
                            OutlinedButton.icon(
                              onPressed: loading
                                  ? null
                                  : () => filters(context, types),
                              style: OutlinedButton.styleFrom(
                                minimumSize: const Size(0, 40),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                ),
                              ),
                              icon: const Icon(Icons.tune_rounded, size: 17),
                              label: Text(
                                filtered ? 'Filtered' : 'Filters',
                                style: const TextStyle(fontSize: 12),
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
                                if (type.isNotEmpty)
                                  filterChip('${types[type] ?? type}', () {
                                    setState(() => type = '');
                                    load();
                                  }),
                                if (from.isNotEmpty || to.isNotEmpty)
                                  filterChip(period, () {
                                    setState(() {
                                      from = '';
                                      to = '';
                                    });
                                    load();
                                  }),
                                TextButton(
                                  onPressed: loading
                                      ? null
                                      : () {
                                          setState(() {
                                            from = '';
                                            to = '';
                                            type = '';
                                          });
                                          load();
                                        },
                                  child: const Text('Clear all'),
                                ),
                              ],
                            ),
                          ),
                        const SizedBox(height: 14),
                        if (loading)
                          const Padding(
                            padding: EdgeInsets.only(bottom: 14),
                            child: LinearProgressIndicator(minHeight: 3),
                          ),
                        if (error.isNotEmpty)
                          Container(
                            margin: const EdgeInsets.only(bottom: 14),
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
                                    color: Color(0xFFB42318),
                                    fontSize: 13,
                                  ),
                                ),
                                TextButton(
                                  onPressed: loading ? null : load,
                                  child: const Text('Try again'),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                  if (entries.isEmpty && !loading && error.isEmpty)
                    SliverFillRemaining(
                      hasScrollBody: false,
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(24, 24, 24, 40),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(18),
                              decoration: const BoxDecoration(
                                color: Color(0xFFEAECF0),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.swap_horiz_rounded,
                                size: 30,
                                color: Color(0xFF98A2B3),
                              ),
                            ),
                            const SizedBox(height: 14),
                            const Text(
                              'No transactions yet',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              filtered ? 'Try another period or entry type.' : 'Cash received and expense entries will appear here.',
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ),
                    )
                  else
                    SliverPadding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      sliver: SliverList.builder(
                        itemCount: entries.length,
                        itemBuilder: (context, i) =>
                            transactionCard(context, entries[i]),
                      ),
                    ),
                  if (expenseNumber(pagination['pages']) > 1)
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            IconButton(
                              tooltip: 'Previous page',
                              onPressed: !loading && page > 1
                                  ? () => load(nextPage: page - 1)
                                  : null,
                              icon: const Icon(Icons.chevron_left_rounded),
                            ),
                            Text(
                              'Page $page of ${pagination['pages']}',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                            IconButton(
                              tooltip: 'Next page',
                              onPressed:
                                  !loading &&
                                      page < expenseNumber(pagination['pages'])
                                  ? () => load(nextPage: page + 1)
                                  : null,
                              icon: const Icon(Icons.chevron_right_rounded),
                            ),
                          ],
                        ),
                      ),
                    ),
                  const SliverToBoxAdapter(child: SizedBox(height: 24)),
                ],
              ),
            ),
          ),
        );
      },
    ),
  );

  Widget balanceCard(BuildContext context, dynamic balance) => Container(
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      border: Border.all(color: const Color(0xFFEAECF0)),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFFFDF0F1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.account_balance_wallet_outlined,
                color: ExpenseDesign.accent,
                size: 22,
              ),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                'Cash in hand',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: ExpenseDesign.muted,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 18),
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            amount(balance),
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w700,
              letterSpacing: -.8,
              color: expenseNumber(balance) < 0
                  ? ExpenseDesign.accent
                  : ExpenseDesign.ink,
            ),
          ),
        ),
        const SizedBox(height: 5),
        Text(
          'Your current available balance',
          style: Theme.of(context).textTheme.bodySmall,
        ),
        if (expenseNumber(balance) < 0)
          Container(
            margin: const EdgeInsets.only(top: 14),
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFFFEF3F2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.info_outline_rounded,
                  size: 16,
                  color: ExpenseDesign.accent,
                ),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'You have spent more than the cash received.',
                    style: TextStyle(color: ExpenseDesign.accent, fontSize: 12),
                  ),
                ),
              ],
            ),
          ),
      ],
    ),
  );
  Widget summaryCard(
    BuildContext context,
    String label,
    dynamic value,
    IconData icon,
    Color color,
  ) => Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: const Color(0xFFEAECF0)),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 19, color: color),
        const SizedBox(height: 10),
        SizedBox(
          height: 34,
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              color: ExpenseDesign.muted,
              height: 1.4,
            ),
          ),
        ),
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            amount(value),
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ),
      ],
    ),
  );
  Widget filterChip(String label, VoidCallback remove) => InputChip(
    onDeleted: loading ? null : remove,
    label: Text(label, style: const TextStyle(fontSize: 11)),
    deleteIcon: const Icon(Icons.close_rounded, size: 15),
    backgroundColor: const Color(0xFFFDF0F1),
    side: BorderSide.none,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
  );

  Widget transactionCard(BuildContext context, Map<String, dynamic> entry) {
    final credit = entry['direction'] == 'credit';
    final color = credit ? const Color(0xFF067647) : ExpenseDesign.accent;
    final expense = expenseId(entry['expense']);
    final status = '${entry['expense_status'] ?? ''}';
    final statusColor = status == 'approved'
        ? const Color(0xFF067647)
        : status == 'submitted'
        ? const Color(0xFF175CD3)
        : ExpenseDesign.muted;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: Color(0xFFEAECF0)),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: expense.isEmpty || status == 'deleted'
              ? null
              : () => Get.to(() => ExpenseDetailScreen(id: expense)),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: .08),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        credit
                            ? Icons.south_west_rounded
                            : Icons.north_east_rounded,
                        size: 20,
                        color: color,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      flex: 5,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${entry['type_label'] ?? entry['type'] ?? ''}',
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${entry['txn_no'] ?? ''}',
                            style: const TextStyle(
                              fontSize: 11,
                              color: ExpenseDesign.muted,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      flex: 4,
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            '${credit ? '+' : '−'}${expenseMoney(entry['amount'])}',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: color,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                if ('${entry['expense_no'] ?? ''}'.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            '${entry['expense_no']}',
                            style: const TextStyle(
                              fontSize: 12,
                              color: ExpenseDesign.muted,
                            ),
                          ),
                        ),
                        if (status.isNotEmpty)
                          Flexible(
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: statusColor.withValues(alpha: .08),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                expenseStatusLabel(status),
                                style: TextStyle(
                                  fontSize: 10,
                                  color: statusColor,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        if (expense.isNotEmpty)
                          const Padding(
                            padding: EdgeInsets.only(left: 4),
                            child: Icon(
                              Icons.chevron_right_rounded,
                              size: 16,
                              color: ExpenseDesign.muted,
                            ),
                          ),
                      ],
                    ),
                  ),
                if ('${entry['note'] ?? ''}'.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: Text(
                      '${entry['note']}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
                if (entry['mode'] != null ||
                    '${entry['reference'] ?? ''}'.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      [
                        if (entry['mode'] != null)
                          '${entry['mode']}'.toUpperCase(),
                        '${entry['reference'] ?? ''}',
                      ].where((v) => v.isNotEmpty).join(' · '),
                      style: const TextStyle(
                        fontSize: 11,
                        color: ExpenseDesign.muted,
                      ),
                    ),
                  ),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Divider(height: 1, color: Color(0xFFF2F4F7)),
                ),
                Row(
                  children: [
                    const Icon(
                      Icons.calendar_today_outlined,
                      size: 12,
                      color: ExpenseDesign.muted,
                    ),
                    const SizedBox(width: 5),
                    Expanded(
                      child: Text(
                        '${entry['business_date'] ?? expenseDay(entry['entry_date'])}',
                        style: const TextStyle(
                          fontSize: 10,
                          color: ExpenseDesign.muted,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        'Balance ${expenseMoney(entry['running_balance'])}',
                        textAlign: TextAlign.right,
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: ExpenseDesign.muted,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> filters(BuildContext context, Map<String, dynamic> types) async {
    String selectedType = type, start = from, end = to;
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
          final valid =
              start.isEmpty || end.isEmpty || start.compareTo(end) <= 0;
          Future<void> pick(bool first) async {
            final date = await showDatePicker(
              context: context,
              initialDate:
                  DateTime.tryParse(first ? start : end) ?? DateTime.now(),
              firstDate: DateTime(2020),
              lastDate: DateTime.now(),
            );
            if (date != null && context.mounted) {
              set(() {
                if (first) {
                  start = expenseDay(date);
                } else {
                  end = expenseDay(date);
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
                (first ? start : end).isEmpty
                    ? 'Any date'
                    : (first ? start : end),
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
                          'Filter transactions',
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
                    key: ValueKey(selectedType),
                    initialValue: selectedType,
                    isExpanded: true,
                    decoration: const InputDecoration(labelText: 'Entry type'),
                    items: [
                      const DropdownMenuItem(
                        value: '',
                        child: Text('All entries'),
                      ),
                      for (final entry in types.entries)
                        DropdownMenuItem(
                          value: entry.key,
                          child: Text(
                            '${entry.value}',
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                    ],
                    onChanged: (v) => set(() => selectedType = v ?? ''),
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
                            selectedType = '';
                            start = '';
                            end = '';
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
      setState(() {
        type = selectedType;
        from = start;
        to = end;
      });
      await load();
    }
  }
}
