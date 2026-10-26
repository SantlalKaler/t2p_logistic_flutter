import 'package:flutter/material.dart';

import '../../../../domain/Model/expense/expense_v1.dart';

/// Read-only order information from the expense order lookups (API guide v1.2).
class ExpenseOrderInfo extends StatelessWidget {
  final Map<String, dynamic> order;
  final bool purchase;
  const ExpenseOrderInfo({
    super.key,
    required this.order,
    required this.purchase,
  });

  @override
  Widget build(BuildContext context) {
    final city = expenseMap(order[purchase ? 'order_city' : 'vendor_city']);
    final name = '${city['name'] ?? ''}'.trim();
    final purchaseCity = '${expenseMap(order['vendor_city'])['name'] ?? ''}'
        .trim();
    final date = expenseDay(order['delivery_date']);
    final slot = '${order['timeslot'] ?? ''}'.trim();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (purchase && purchaseCity.isNotEmpty)
          Text(
            'Purchase city: $purchaseCity',
            style: const TextStyle(fontSize: 12),
          ),
        Text(
          '${purchase ? 'Delivery' : 'Purchase'} city: ${name.isEmpty ? 'Not available' : name}',
          style: const TextStyle(fontSize: 12),
        ),
        Text(
          'Delivery date: ${date.isEmpty ? 'Not available' : date}',
          style: const TextStyle(fontSize: 12),
        ),
        if (slot.isNotEmpty) Text(slot, style: const TextStyle(fontSize: 12)),
      ],
    );
  }
}
