import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../domain/Model/expense/expense_v1.dart';

/// A compact multi-select dropdown. Selection is applied as one batch so product
/// lookups run once after the user has finished choosing orders.
class ExpenseOrderDropdown extends StatefulWidget {
  final List<Map<String, dynamic>> orders;
  final Set<String> selected;
  final bool enabled;
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
            height: math.min(390, MediaQuery.sizeOf(context).height * .48),
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
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          itemCount: widget.orders.length,
                          itemBuilder: (context, index) {
                            final order = widget.orders[index],
                                id = expenseId(widget.orders[index]);
                            final selected = selection.contains(id);
                            return CheckboxListTile(
                              dense: true,
                              controlAffinity: ListTileControlAffinity.leading,
                              value: selected,
                              activeColor: scheme.primary,
                              title: Text(
                                '${order['orderid'] ?? id}',
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              subtitle:
                                  expenseMap(order['vendor_city'])['name'] ==
                                      null
                                  ? null
                                  : Text(
                                      '${expenseMap(order['vendor_city'])['name']}',
                                      style: const TextStyle(fontSize: 12),
                                    ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              onChanged:
                                  searching ||
                                      !selected && selection.length >= 50
                                  ? null
                                  : (v) => setState(() {
                                      if (v == true) {
                                        selection.add(id);
                                      } else {
                                        selection.remove(id);
                                      }
                                    }),
                            );
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
