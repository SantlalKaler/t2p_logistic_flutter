import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../domain/Model/duty.dart';
import '../expense_management/components/expense_design.dart';

class DutySurface extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  const DutySurface({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
  });
  @override
  Widget build(BuildContext context) => Container(
    padding: padding,
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      border: Border.all(color: const Color(0xFFEAECF0)),
    ),
    child: child,
  );
}

class DutyBadge extends StatelessWidget {
  final String label;
  final bool active;
  const DutyBadge({super.key, required this.label, this.active = false});
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
    decoration: BoxDecoration(
      color: active ? const Color(0xFFECFDF3) : const Color(0xFFF2F4F7),
      borderRadius: BorderRadius.circular(20),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 6,
          height: 6,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: active ? const Color(0xFF12B76A) : ExpenseDesign.muted,
          ),
        ),
        const SizedBox(width: 5),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: active ? const Color(0xFF067647) : ExpenseDesign.muted,
          ),
        ),
      ],
    ),
  );
}

class DutyMetric extends StatelessWidget {
  final IconData icon;
  final String label, value;
  const DutyMetric({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
  });
  @override
  Widget build(BuildContext context) => Expanded(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 13, color: ExpenseDesign.muted),
            const SizedBox(width: 4),
            Flexible(
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 10,
                  color: ExpenseDesign.muted,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: ExpenseDesign.ink,
          ),
        ),
      ],
    ),
  );
}

String dutyTime(dynamic value) {
  final date = DateTime.tryParse('$value');
  return date == null
      ? 'Not available'
      : '${DateFormat('dd MMM, h:mm a').format(date.toUtc().add(const Duration(hours: 5, minutes: 30)))} IST';
}

class DutySessionCard extends StatelessWidget {
  final DutySession duty;
  final VoidCallback? onEnterKm;
  const DutySessionCard({super.key, required this.duty, this.onEnterKm});
  @override
  Widget build(BuildContext context) => DutySurface(
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
                Icons.route_rounded,
                color: ExpenseDesign.accent,
                size: 20,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    duty.isTotal ? 'Total duty' : duty.orderNumber,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    dutyTime(duty.json['started_at']),
                    style: const TextStyle(
                      fontSize: 11,
                      color: ExpenseDesign.muted,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 6),
            DutyBadge(
              label: duty.isOn
                  ? 'Active'
                  : duty.needsActualKm
                  ? 'Km pending'
                  : 'Completed',
              active: duty.isOn,
            ),
          ],
        ),
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 14),
          child: Divider(height: 1),
        ),
        _place(Icons.trip_origin_rounded, 'From', duty.json['start_address']),
        Padding(
          padding: const EdgeInsets.only(left: 7),
          child: Container(
            width: 1,
            height: 14,
            color: const Color(0xFFD0D5DD),
          ),
        ),
        _place(Icons.location_on_outlined, 'To', duty.json['end_address']),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFFF8F9FC),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              DutyMetric(
                icon: Icons.route_outlined,
                label: 'Distance',
                value: '${duty.distance.toStringAsFixed(2)} km',
              ),
              DutyMetric(
                icon: Icons.schedule_rounded,
                label: 'Duration',
                value:
                    '${duty.seconds ~/ 3600}h ${(duty.seconds % 3600) ~/ 60}m',
              ),
              DutyMetric(
                icon: Icons.payments_outlined,
                label: 'Amount',
                value: '₹${duty.amount.toStringAsFixed(2)}',
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        if (duty.actualKm != null) ...[
          Text('Actual km: ${duty.actualKm!.toStringAsFixed(2)} km'),
          const SizedBox(height: 6),
          Text(
            'Difference: ${duty.differenceKm?.toStringAsFixed(2) ?? '—'} km',
          ),
          const SizedBox(height: 12),
        ],
        if (duty.needsActualKm) ...[
          const Text(
            'Pending actual km · Unpaid',
            style: TextStyle(color: ExpenseDesign.accent),
          ),
          if (onEnterKm != null)
            TextButton.icon(
              onPressed: onEnterKm,
              icon: const Icon(Icons.edit_road_outlined),
              label: const Text('Enter km'),
            ),
          const SizedBox(height: 12),
        ],
        Text(
          '${duty.rate == 0 ? 'Rate not set' : '₹${duty.rate}/km'}  ·  ${duty.isOn ? 'Duty in progress' : 'Stopped ${dutyTime(duty.json['ended_at'])}'}',
          style: const TextStyle(fontSize: 11, color: ExpenseDesign.muted),
        ),
      ],
    ),
  );
  Widget _place(IconData icon, String label, dynamic address) => Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Icon(
        icon,
        size: 16,
        color: label == 'From' ? ExpenseDesign.muted : ExpenseDesign.accent,
      ),
      const SizedBox(width: 10),
      Expanded(
        child: Text(
          '$label: ${address ?? (duty.isOn ? 'Available after duty ends' : 'Address unavailable')}',
          style: const TextStyle(
            fontSize: 12,
            color: ExpenseDesign.ink,
            height: 1.5,
          ),
        ),
      ),
    ],
  );
}
