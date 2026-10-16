import 'package:intl/intl.dart';

Map<String, dynamic> expenseMap(dynamic value) =>
    value is Map ? Map<String, dynamic>.from(value) : <String, dynamic>{};
List<Map<String, dynamic>> expenseMaps(dynamic value) =>
    value is List ? value.map(expenseMap).toList() : <Map<String, dynamic>>[];
String expenseId(dynamic value) => value is Map
    ? (value['_id'] ?? value['id'] ?? '').toString()
    : (value ?? '').toString();
num expenseNumber(dynamic value) => num.tryParse('$value') ?? 0;
String expenseMoney(dynamic paise) =>
    '₹${(expenseNumber(paise) / 100).toStringAsFixed(2)}';
String expenseRupees(dynamic paise) =>
    (expenseNumber(paise) / 100).toStringAsFixed(2);
String expenseDay(dynamic value) {
  final parsed = DateTime.tryParse('${value ?? ''}');
  if (parsed == null) return '';
  return DateFormat('yyyy-MM-dd').format(
    parsed.isUtc ? parsed.add(const Duration(hours: 5, minutes: 30)) : parsed,
  );
}

String expenseToday() => DateFormat('yyyy-MM-dd')
    .format(DateTime.now().toUtc().add(const Duration(hours: 5, minutes: 30)));
String expenseStatusLabel(String status) =>
    const {
      'draft': 'Draft',
      'submitted': 'Pending approval',
      'approved': 'Approved',
      'rejected': 'Rejected',
      'cancelled': 'Cancelled',
    }[status] ??
    status;

class ExpenseRecord {
  final Map<String, dynamic> json;
  ExpenseRecord.fromJson(dynamic value) : json = expenseMap(value);
  String get id => expenseId(json);
  String get number => '${json['expense_no'] ?? ''}';
  String get category => '${json['category'] ?? ''}';
  String get label => '${json['category_label'] ?? category}';
  String get status => '${json['status'] ?? ''}';
  String get date => expenseDay(json['business_date'] ?? json['expense_date']);
  Map<String, dynamic> get details => expenseMap(json['details']);
  num get total => expenseNumber(expenseMap(json['amount'])['total']);
  int? get version => int.tryParse('${json['version']}');
}

class ExpenseDetail {
  final Map<String, dynamic> json;
  ExpenseDetail.fromJson(dynamic value) : json = expenseMap(value);
  ExpenseRecord get expense => ExpenseRecord.fromJson(json['expense']);
  bool can(String action) => expenseMap(json['actions'])[action] == true;
  List<Map<String, dynamic>> get documents =>
      expenseMaps(expense.json['documents'])
          .where((d) => d['removed'] != true)
          .toList();
}

class ExpenseApiException implements Exception {
  final int? statusCode;
  final String message;
  final Map<String, String> fields;
  final int? retryAfter;
  ExpenseApiException(
    this.statusCode,
    this.message, {
    this.fields = const {},
    this.retryAfter,
  });
  @override
  String toString() => message;
}
