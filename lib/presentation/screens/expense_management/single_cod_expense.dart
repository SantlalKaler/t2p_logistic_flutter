import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../domain/Model/expense/expense_v1.dart';
import '../../widgets/app_back_button.dart';
import '../../widgets/app_bar.dart';
import '../../widgets/app_scaffold.dart';
import 'expense_detail.dart';
import 'components/expense_design.dart';

class SingleExpenseItem extends StatelessWidget {
  final ExpenseRecord expense;
  const SingleExpenseItem({super.key, required this.expense});
  @override
  Widget build(BuildContext context) {
    final color = switch (expense.status) {
      'approved' => const Color(0xFF067647),
      'submitted' => const Color(0xFF175CD3),
      'rejected' => const Color(0xFFB42318),
      _ => ExpenseDesign.muted,
    };
    final icon = switch (expense.category) {
      'FOOD_PURCHASE' => Icons.restaurant_outlined,
      'PETROL' => Icons.local_gas_station_outlined,
      'INTERCITY_LOGISTICS' => Icons.local_shipping_outlined,
      'DELIVERY' => Icons.delivery_dining_outlined,
      'TRAVEL' => Icons.route_outlined,
      'CANCELLED_ORDER' => Icons.inventory_2_outlined,
      _ => Icons.receipt_long_outlined,
    };
    final count = expenseNumber(expense.json['document_count']).toInt();
    final reason =
        '${expenseMap(expense.json['review'])['rejection_reason'] ?? ''}';
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
          onTap: () => Get.to(() => ExpenseDetailScreen(id: expense.id)),
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
                        color: const Color(0xFFFDF0F1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(icon, size: 21, color: ExpenseDesign.accent),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 5,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            expense.label,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            expense.number,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
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
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              expenseMoney(expense.total),
                              style: const TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w700,
                                color: ExpenseDesign.ink,
                              ),
                            ),
                          ),
                          const SizedBox(height: 5),
                          const Icon(
                            Icons.chevron_right_rounded,
                            size: 18,
                            color: Color(0xFF98A2B3),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    const Icon(
                      Icons.calendar_today_outlined,
                      size: 13,
                      color: ExpenseDesign.muted,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        expense.date,
                        style: const TextStyle(
                          fontSize: 11,
                          color: ExpenseDesign.muted,
                        ),
                      ),
                    ),
                    if (count > 0) ...[
                      const Icon(
                        Icons.attach_file_rounded,
                        size: 13,
                        color: ExpenseDesign.muted,
                      ),
                      Text(
                        '$count',
                        style: const TextStyle(
                          fontSize: 11,
                          color: ExpenseDesign.muted,
                        ),
                      ),
                      const SizedBox(width: 12),
                    ],
                    Flexible(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 9,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: color.withValues(alpha: .08),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          expenseStatusLabel(expense.status),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: color,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                if (expense.status == 'rejected' && reason.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: Text(
                      reason,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xFFB42318),
                        fontSize: 12,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class ExpensePage extends StatelessWidget {
  final String title;
  final Widget body;
  final List<Widget>? actions;
  final Widget? floatingActionButton;
  const ExpensePage({
    super.key,
    required this.title,
    required this.body,
    this.actions,
    this.floatingActionButton,
  });
  @override
  Widget build(BuildContext context) => AppScaffold(
    appBar: appBar(
      title: title,
      leading: const AppBackButton(),
      actions: actions ?? [],
    ),
    body: body,
    floatingActionButton: floatingActionButton,
  );
}
