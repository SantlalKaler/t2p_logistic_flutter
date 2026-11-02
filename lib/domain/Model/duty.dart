import 'expense/expense_v1.dart';

class DutySession {
  final Map<String, dynamic> json;
  DutySession(this.json);
  String get id => '${json['session_id'] ?? ''}';
  bool get isOn => json['status'] == 'on';
  String get orderId => expenseId(json['order']);
  String get orderNumber => '${expenseMap(json['order'])['orderid'] ?? ''}';
  bool get isTotal => json['order'] == null;
  num get distance => expenseNumber(json['distance_km']);
  num get rate => expenseNumber(json['rate_per_km']);
  num get amount => expenseNumber(json['amount']);
  num? get actualKm =>
      json['actual_km'] == null ? null : expenseNumber(json['actual_km']);
  num? get differenceKm => json['difference_km'] == null
      ? null
      : expenseNumber(json['difference_km']);
  bool get needsActualKm => !isOn && json['needs_actual_km'] == true;
  int get seconds => expenseNumber(json['duration_seconds']).toInt();
  bool matches(String order) =>
      !isTotal && (orderId == order || orderNumber == order);
  String get summary =>
      '${json['start_address'] ?? 'Address unavailable'} → '
      '${json['end_address'] ?? 'Address unavailable'}\n'
      '${distance.toStringAsFixed(2)} km · ${seconds ~/ 3600}h ${(seconds % 3600) ~/ 60}m · '
      '${rate == 0 ? 'Rate not set' : '₹$rate/km'} · ₹${amount.toStringAsFixed(2)}';
}

bool dutyOrderClosed(String status) {
  final value = status.toLowerCase().replaceAll(' ', '_');
  return value == 'delivered' ||
      value == 'delivered_to_customer' ||
      value.contains('cancel') ||
      value.contains('fail') ||
      value == 'closed';
}
