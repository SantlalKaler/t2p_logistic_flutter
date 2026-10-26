import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../domain/Model/expense/expense_v1.dart';
import 'expense_order_info.dart';
import 'expense_design.dart';

/// A compact multi-select dropdown. Selection is applied as one batch so product
/// lookups run once after the user has finished choosing orders.
class ExpenseOrderDropdown extends StatefulWidget {
  final List<Map<String, dynamic>> orders;
  final Set<String> selected;
  final bool enabled;
  final String? currentExpenseId;
  final ValueChanged<String>? onOpenExpense;
  final String? errorText;
  final Future<void> Function(String) onSearch;
  final ValueChanged<Set<String>> onApply;
  const ExpenseOrderDropdown({
    super.key,
    required this.orders,
    required this.selected,
    required this.onSearch,
    required this.onApply,
    this.enabled = true,
    this.currentExpenseId,
    this.onOpenExpense,
    this.errorText,
  });
  @override
  State<ExpenseOrderDropdown> createState() => _ExpenseOrderDropdownState();
}

class _ExpenseOrderDropdownState extends State<ExpenseOrderDropdown> {
  final menu = MenuController();
  final search = TextEditingController();
  final ordersScroll = ScrollController();
  Set<String> selection = {};
  bool searching = false;
  String? searchError;
  @override
  void dispose() {
    search.dispose();
    ordersScroll.dispose();
    super.dispose();
  }

  Future<void> findOrders() async {
    if (searching) return;
    setState(() {
      searching = true;
      searchError = null;
    });
    try {
      await widget.onSearch(search.text.trim());
    } catch (e) {
      if (mounted) setState(() => searchError = '$e');
    } finally {
      if (mounted) setState(() => searching = false);
    }
  }

  Widget orderCard(Map<String, dynamic> order) {
    final id = expenseId(order);
    final linked = expenseMap(order['expense']);
    final linkedId = expenseId(linked);
    final hasExpense =
        linkedId.isNotEmpty && linkedId != widget.currentExpenseId;
    final selected = selection.contains(id);
    final canSelect = !searching && (selected || selection.length < 50);
    void toggle() => setState(() {
      if (selected) {
        selection.remove(id);
      } else {
        selection.add(id);
      }
    });
    final status = '${linked['status'] ?? ''}';
    final statusColor = switch (status) {
      'submitted' => const Color(0xFF175CD3),
      'approved' => const Color(0xFF067647),
      'rejected' => ExpenseDesign.accent,
      _ => ExpenseDesign.muted,
    };
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: selected && !hasExpense ? const Color(0xFFFFF7F7) : Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: selected && !hasExpense
                ? ExpenseDesign.accent
                : const Color(0xFFE4E7EC),
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: hasExpense || !canSelect ? null : toggle,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        '${order['orderid'] ?? id}',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: ExpenseDesign.ink,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    if (hasExpense)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: statusColor.withValues(alpha: .08),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          expenseStatusLabel(status),
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: statusColor,
                          ),
                        ),
                      )
                    else
                      SizedBox(
                        width: 32,
                        height: 32,
                        child: Checkbox(
                          value: selected,
                          activeColor: ExpenseDesign.accent,
                          onChanged: canSelect ? (_) => toggle() : null,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                DefaultTextStyle.merge(
                  style: const TextStyle(
                    color: ExpenseDesign.muted,
                    height: 1.6,
                  ),
                  child: ExpenseOrderInfo(order: order, purchase: true),
                ),
                if (hasExpense) ...[
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 10),
                    child: Divider(height: 1, color: Color(0xFFEAECF0)),
                  ),
                  const Text(
                    'Purchase already recorded',
                    style: TextStyle(fontSize: 11, color: ExpenseDesign.muted),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          '${linked['expense_no'] ?? 'Existing expense'}',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: ExpenseDesign.ink,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      TextButton.icon(
                        onPressed: searching || widget.onOpenExpense == null
                            ? null
                            : () {
                                menu.close();
                                widget.onOpenExpense!(linkedId);
                              },
                        style: TextButton.styleFrom(
                          foregroundColor: ExpenseDesign.accent,
                          backgroundColor: const Color(0xFFFDF0F1),
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          textStyle: const TextStyle(
                            fontFamily: 'Roboto',
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        icon: const Icon(Icons.open_in_new_rounded, size: 14),
                        label: const Text('Open expense'),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final width = constraints.maxWidth;
      final scheme = Theme.of(context).colorScheme;
      return MenuAnchor(
        controller: menu,
        consumeOutsideTap: true,
        onOpen: () => setState(() {
          selection = Set.of(widget.selected);
          searchError = null;
        }),
        style: MenuStyle(
          padding: const WidgetStatePropertyAll(EdgeInsets.zero),
          backgroundColor: const WidgetStatePropertyAll(Colors.white),
          surfaceTintColor: const WidgetStatePropertyAll(Colors.transparent),
          shape: WidgetStatePropertyAll(
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
          side: WidgetStatePropertyAll(
            BorderSide(color: scheme.outlineVariant),
          ),
          elevation: const WidgetStatePropertyAll(8),
        ),
        menuChildren: [
          SizedBox(
            width: width,
            height: math.min(520, MediaQuery.sizeOf(context).height * .62),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: TextField(
                    controller: search,
                    textInputAction: TextInputAction.search,
                    decoration: InputDecoration(
                      hintText: 'Search order number',
                      prefixIcon: const Icon(Icons.search_rounded),
                      suffixIcon: IconButton(
                        onPressed: searching ? null : findOrders,
                        icon: const Icon(Icons.arrow_forward_rounded),
                      ),
                    ),
                    onSubmitted: (_) => findOrders(),
                  ),
                ),
                if (searching) const LinearProgressIndicator(minHeight: 2),
                if (searchError != null)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Text(
                      searchError!,
                      style: TextStyle(color: scheme.error),
                    ),
                  ),
                Expanded(
                  child: widget.orders.isEmpty
                      ? const Center(child: Text('No orders found'))
                      : ListView.builder(
                          controller: ordersScroll,
                          primary: false,
                          padding: const EdgeInsets.fromLTRB(12, 0, 12, 2),
                          itemCount: widget.orders.length,
                          itemBuilder: (context, index) {
                            return orderCard(widget.orders[index]);
                          },
                        ),
                ),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    border: Border(
                      top: BorderSide(color: scheme.outlineVariant),
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          '${selection.length}/50 selected',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ),
                      FilledButton(
                        onPressed: searching
                            ? null
                            : () {
                                menu.close();
                                widget.onApply(Set.of(selection));
                              },
                        child: const Text('Apply'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
        builder: (context, controller, child) => InkWell(
          key: const ValueKey('expense-order-dropdown'),
          borderRadius: BorderRadius.circular(12),
          onTap: !widget.enabled
              ? null
              : () {
                  if (controller.isOpen) {
                    controller.close();
                  } else {
                    controller.open();
                  }
                },
          child: InputDecorator(
            decoration: InputDecoration(
              labelText: 'Orders',
              errorText: widget.errorText,
              prefixIcon: const Icon(Icons.receipt_long_outlined),
              suffixIcon: Icon(
                controller.isOpen
                    ? Icons.keyboard_arrow_up_rounded
                    : Icons.keyboard_arrow_down_rounded,
              ),
            ),
            child: Text(
              widget.selected.isEmpty
                  ? 'Select orders'
                  : '${widget.selected.length} order${widget.selected.length == 1 ? '' : 's'} selected',
              style: TextStyle(
                fontSize: 14,
                color: widget.selected.isEmpty
                    ? scheme.onSurfaceVariant
                    : scheme.onSurface,
              ),
            ),
          ),
        ),
      );
    },
  );
}
