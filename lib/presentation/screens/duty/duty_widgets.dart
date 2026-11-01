import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../domain/Model/duty.dart';
import '../../../domain/mapper/order_mapper.dart';
import '../expense_management/components/expense_design.dart';
import 'duty_controller.dart';
import 'duty_design.dart';
import 'duty_history.dart';

class DutyPanel extends StatelessWidget {
  const DutyPanel({super.key});
  @override
  Widget build(BuildContext context) => Theme(
    data: ExpenseDesign.theme(context),
    child: GetBuilder<DutyController>(
      builder: (c) {
        final disabled =
            c.busy ||
            (c.refreshing && !c.on) ||
            !c.supported ||
            (!c.ready && !c.on);
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: DutySurface(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      padding: const EdgeInsets.all(7),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFDF0F1),
                        borderRadius: BorderRadius.circular(13),
                      ),
                      child: Image.asset('assets/images/app_icon_small.png'),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Total Duty',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            c.on && !c.session!.isTotal
                                ? 'On order ${c.session!.orderNumber}'
                                : 'Your shift & travel at a glance',
                            style: const TextStyle(
                              fontSize: 11,
                              color: ExpenseDesign.muted,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Switch.adaptive(
                      value: c.on,
                      activeTrackColor: ExpenseDesign.accent,
                      onChanged: disabled
                          ? null
                          : (value) => value ? c.start() : c.stop(),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                DutyBadge(
                  label: c.on
                      ? 'On duty'
                      : c.pendingStop != null
                      ? 'Off · Sync pending'
                      : 'Off duty',
                  active: c.on,
                ),
                if (c.on) ...[
                  const SizedBox(height: 16),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      DutyMetric(
                        icon: Icons.route_rounded,
                        label: 'Distance',
                        value: '${c.session!.distance.toStringAsFixed(2)} km',
                      ),
                      DutyMetric(
                        icon: Icons.schedule_rounded,
                        label: 'Duration',
                        value:
                            '${c.session!.seconds ~/ 3600}h ${(c.session!.seconds % 3600) ~/ 60}m',
                      ),
                      DutyMetric(
                        icon: Icons.payments_outlined,
                        label: 'Amount',
                        value: '₹${c.session!.amount.toStringAsFixed(2)}',
                      ),
                    ],
                  ),
                ],
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Divider(height: 1),
                ),
                Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        borderRadius: BorderRadius.circular(8),
                        onTap: () => Get.to(() => const DutyHistoryScreen()),
                        child: const Padding(
                          padding: EdgeInsets.symmetric(vertical: 6),
                          child: Row(
                            children: [
                              Icon(
                                Icons.history_rounded,
                                size: 18,
                                color: ExpenseDesign.accent,
                              ),
                              SizedBox(width: 7),
                              Text(
                                'Duty history',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: ExpenseDesign.accent,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              SizedBox(width: 4),
                              Icon(
                                Icons.arrow_forward_rounded,
                                size: 14,
                                color: ExpenseDesign.accent,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    if (c.busy || c.refreshing)
                      const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    else
                      IconButton(
                        tooltip: 'Sync duty',
                        visualDensity: VisualDensity.compact,
                        onPressed: () => c.reconcile(),
                        icon: const Icon(
                          Icons.sync_rounded,
                          size: 20,
                          color: ExpenseDesign.muted,
                        ),
                      ),
                  ],
                ),
                if (!c.supported)
                  const Text(
                    'Duty tracking requires Android or iOS.',
                    style: TextStyle(fontSize: 12, color: ExpenseDesign.muted),
                  ),
                if (c.error.isNotEmpty || c.warning.isNotEmpty)
                  Container(
                    margin: const EdgeInsets.only(top: 12),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFFAEB),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          Icons.info_outline_rounded,
                          size: 16,
                          color: Color(0xFFB54708),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            [
                              c.error,
                              c.warning,
                            ].where((s) => s.isNotEmpty).join('\n'),
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFF93370D),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    ),
  );
}

class OrderDutyButton extends StatelessWidget {
  final CommonOrder order;
  const OrderDutyButton({super.key, required this.order});
  @override
  Widget build(BuildContext context) => Theme(
    data: ExpenseDesign.theme(context),
    child: GetBuilder<DutyController>(
      builder: (c) {
        if (!c.orderControls) return const SizedBox.shrink();
        final current =
            c.on &&
            (c.session!.matches(order.id ?? '') ||
                c.session!.matches(order.orderId ?? ''));
        if (!current && dutyOrderClosed(order.orderStatus ?? '')) {
          return const SizedBox.shrink();
        }
        final disabled =
            c.busy ||
            (c.refreshing && !c.on) ||
            (!c.ready && !c.on) ||
            !c.supported ||
            (c.on && !current);
        final label = current
            ? 'Stop Duty'
            : c.on
            ? (c.session!.isTotal
                  ? 'Total duty is ON'
                  : 'On order ${c.session!.orderNumber}')
            : 'Start Duty';
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                backgroundColor: current
                    ? const Color(0xFFFDF0F1)
                    : Colors.white,
                side: BorderSide(
                  color: current
                      ? const Color(0xFFF3D5D9)
                      : const Color(0xFFD0D5DD),
                ),
              ),
              icon: Icon(
                current
                    ? Icons.stop_circle_outlined
                    : c.on
                    ? Icons.lock_outline_rounded
                    : Icons.play_circle_outline_rounded,
                size: 19,
              ),
              label: Text(label, textAlign: TextAlign.center),
              onPressed: disabled
                  ? null
                  : () => current ? c.stop() : c.start(order: order.id),
            ),
          ),
        );
      },
    ),
  );
}
