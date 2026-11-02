import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../domain/Model/duty.dart';
import '../../../domain/Model/expense/expense_v1.dart';
import 'duty_controller.dart';
import 'duty_design.dart';
import '../expense_management/components/expense_design.dart';

class DutyHistoryScreen extends StatefulWidget {
  const DutyHistoryScreen({super.key});
  @override
  State<DutyHistoryScreen> createState() => _DutyHistoryScreenState();
}

class _DutyHistoryScreenState extends State<DutyHistoryScreen> {
  final order = TextEditingController();
  String from = '', to = '', side = '', error = '';
  bool loading = false;
  int page = 1, pages = 1;
  List<Map<String, dynamic>> rows = [];
  Map<String, dynamic> totals = {};
  @override
  void initState() {
    super.initState();
    load();
  }

  @override
  void dispose() {
    order.dispose();
    super.dispose();
  }

  Future<void> load({int next = 1}) async {
    setState(() {
      loading = true;
      error = '';
    });
    try {
      final response = await Get.find<DutyController>().request(
        'history',
        query: {
          'page': next,
          'limit': 20,
          if (from.isNotEmpty) 'from': from,
          if (to.isNotEmpty) 'to': to,
          if (side.isNotEmpty) 'side': side,
          if (order.text.trim().isNotEmpty) 'order': order.text.trim(),
        },
      );
      if (!mounted) return;
      setState(() {
        rows = expenseMaps(response['data']);
        totals = expenseMap(response['totals']);
        page = next;
        pages = expenseNumber(expenseMap(response['pagination'])['pages'])
            .toInt();
      });
    } catch (e) {
      if (mounted) setState(() => error = '$e');
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  Future<void> date(bool start) async {
    final chosen = await showDatePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 1)),
      initialDate: DateTime.now(),
    );
    if (chosen == null || !mounted) return;
    setState(() {
      if (start) {
        from = DateFormat('yyyy-MM-dd').format(chosen);
      } else {
        to = DateFormat('yyyy-MM-dd').format(chosen);
      }
    });
  }

  @override
  Widget build(BuildContext context) => Theme(
    data: ExpenseDesign.theme(context),
    child: Builder(
      builder: (context) => Scaffold(
        appBar: AppBar(
          title: const Text('Duty history'),
          actions: [
            IconButton(
              tooltip: 'Refresh history',
              onPressed: loading ? null : () => load(next: page),
              icon: const Icon(Icons.refresh_rounded),
            ),
          ],
        ),
        body: SafeArea(
          top: false,
          child: RefreshIndicator(
            onRefresh: () => load(next: page),
            child: ListView(
              padding: const EdgeInsets.all(16),
              physics: const AlwaysScrollableScrollPhysics(),
              children: [
                const Text(
                  'Your duty overview',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Trips, distance and duty amounts in one place.',
                  style: TextStyle(fontSize: 12, color: ExpenseDesign.muted),
                ),
                const SizedBox(height: 18),
                DutySurface(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(
                            Icons.account_balance_wallet_outlined,
                            size: 18,
                            color: ExpenseDesign.accent,
                          ),
                          SizedBox(width: 8),
                          Text(
                            'Total duty amount',
                            style: TextStyle(
                              fontSize: 12,
                              color: ExpenseDesign.muted,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(
                        '\u20b9${expenseNumber(totals['amount']).toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.w700,
                          color: ExpenseDesign.ink,
                          letterSpacing: -.8,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          DutyMetric(
                            icon: Icons.route_outlined,
                            label: 'Distance',
                            value:
                                '${expenseNumber(totals['distance_km']).toStringAsFixed(2)} km',
                          ),
                          DutyMetric(
                            icon: Icons.work_history_outlined,
                            label: 'Duties',
                            value: '${totals['duties'] ?? 0}',
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Actual km: ${expenseNumber(totals['actual_km']).toStringAsFixed(2)} km',
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Awaiting actual km: ${totals['awaiting_actual_km'] ?? 0}',
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Across all duties matching your filters',
                        style: TextStyle(
                          fontSize: 10,
                          color: ExpenseDesign.muted,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                DutySurface(
                  padding: EdgeInsets.zero,
                  child: ExpansionTile(
                    shape: const Border(),
                    collapsedShape: const Border(),
                    tilePadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 4,
                    ),
                    childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    leading: const Icon(
                      Icons.tune_rounded,
                      color: ExpenseDesign.accent,
                      size: 20,
                    ),
                    title: const Text(
                      'Filter history',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    subtitle: Text(
                      from.isNotEmpty ||
                              to.isNotEmpty ||
                              side.isNotEmpty ||
                              order.text.isNotEmpty
                          ? 'Custom filters'
                          : 'All dates and orders',
                      style: const TextStyle(
                        fontSize: 11,
                        color: ExpenseDesign.muted,
                      ),
                    ),
                    children: [
                      TextField(
                        controller: order,
                        enabled: !loading,
                        decoration: const InputDecoration(
                          labelText: 'Order number or ID',
                          prefixIcon: Icon(Icons.search_rounded, size: 20),
                        ),
                      ),
                      const SizedBox(height: 14),
                      DropdownButtonFormField<String>(
                        key: ValueKey(side),
                        initialValue: side,
                        decoration: const InputDecoration(
                          labelText: 'Duty side',
                        ),
                        items: const [
                          DropdownMenuItem(value: '', child: Text('All sides')),
                          DropdownMenuItem(
                            value: 'pickup',
                            child: Text('Pickup'),
                          ),
                          DropdownMenuItem(
                            value: 'delivery',
                            child: Text('Delivery'),
                          ),
                        ],
                        onChanged: loading
                            ? null
                            : (s) => setState(() => side = s ?? ''),
                      ),
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: loading ? null : () => date(true),
                              icon: const Icon(
                                Icons.calendar_today_outlined,
                                size: 16,
                              ),
                              label: Text(
                                from.isEmpty ? 'From date' : from,
                                style: const TextStyle(fontSize: 11),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: loading ? null : () => date(false),
                              icon: const Icon(
                                Icons.calendar_today_outlined,
                                size: 16,
                              ),
                              label: Text(
                                to.isEmpty ? 'To date' : to,
                                style: const TextStyle(fontSize: 11),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: loading
                                  ? null
                                  : () {
                                      setState(() {
                                        from = '';
                                        to = '';
                                        side = '';
                                        order.clear();
                                      });
                                      load();
                                    },
                              child: const Text('Clear'),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: FilledButton(
                              onPressed: loading ? null : () => load(),
                              child: const Text('Apply filters'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 22),
                Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'Recent duties',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    Text(
                      '${totals['duties'] ?? 0} duties',
                      style: const TextStyle(
                        fontSize: 12,
                        color: ExpenseDesign.muted,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                if (loading)
                  const Padding(
                    padding: EdgeInsets.only(bottom: 14),
                    child: LinearProgressIndicator(minHeight: 3),
                  ),
                if (error.isNotEmpty)
                  DutySurface(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          error,
                          style: const TextStyle(color: ExpenseDesign.accent),
                        ),
                        TextButton(
                          onPressed: loading ? null : () => load(next: page),
                          child: const Text('Try again'),
                        ),
                      ],
                    ),
                  ),
                if (rows.isEmpty && !loading && error.isEmpty)
                  const DutySurface(
                    padding: EdgeInsets.symmetric(vertical: 36, horizontal: 24),
                    child: Column(
                      children: [
                        Icon(
                          Icons.route_outlined,
                          size: 40,
                          color: Color(0xFF98A2B3),
                        ),
                        SizedBox(height: 14),
                        Text(
                          'No duties yet',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(height: 6),
                        Text(
                          'Completed duties will appear here.\nTry changing your filters.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 12,
                            color: ExpenseDesign.muted,
                          ),
                        ),
                      ],
                    ),
                  ),
                ...rows.map(
                  (row) => Padding(
                    padding: const EdgeInsets.only(bottom: 14),
                    child: DutySessionCard(
                      duty: DutySession(row),
                      onEnterKm: loading
                          ? null
                          : () async {
                              await Get.find<DutyController>().enterActualKm(
                                DutySession(row),
                              );
                              if (mounted) {
                                await load(next: page);
                              }
                            },
                    ),
                  ),
                ),
                if (pages > 1)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        tooltip: 'Previous page',
                        onPressed: loading || page <= 1
                            ? null
                            : () => load(next: page - 1),
                        icon: const Icon(Icons.chevron_left_rounded),
                      ),
                      Text(
                        'Page $page of $pages',
                        style: const TextStyle(
                          fontSize: 12,
                          color: ExpenseDesign.muted,
                        ),
                      ),
                      IconButton(
                        tooltip: 'Next page',
                        onPressed: loading || page >= pages
                            ? null
                            : () => load(next: page + 1),
                        icon: const Icon(Icons.chevron_right_rounded),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}
