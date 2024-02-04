import 'dart:convert';

FinancialLogResponse financialLogResponseFromJson(String str) =>
    FinancialLogResponse.fromJson(json.decode(str));

String financialLogResponseToJson(FinancialLogResponse data) =>
    json.encode(data.toJson());

class FinancialLogResponse {
  FinancialLogResponse({
    String? status,
    List<FinancialLog>? financialLog,
    String? message,
    String? count,
    String? sum,
    String? paid,
  }) {
    _status = status;
    _financialLog = financialLog;
    _message = message;
    _count = count;
    _sum = sum;
    _paid = paid;
  }

  FinancialLogResponse.fromJson(dynamic json) {
    _status = json['status'];
    if (json['result'] != null) {
      _financialLog = [];
      json['result'].forEach((v) {
        _financialLog?.add(FinancialLog.fromJson(v));
      });
    }
    _message = json['message'];
    _count = json['count'].toString();
    _sum = json['sum'].toString();
    _paid = json['paid'].toString();
  }

  String? _status;
  List<FinancialLog>? _financialLog;
  String? _message;
  String? _count;
  String? _sum;
  String? _paid;

  FinancialLogResponse copyWith({
    String? status,
    List<FinancialLog>? financialLog,
    String? message,
    String? count,
    String? sum,
    String? paid,
  }) =>
      FinancialLogResponse(
        status: status ?? _status,
        financialLog: financialLog ?? _financialLog,
        message: message ?? _message,
        count: count ?? _count,
        sum: sum ?? _sum,
        paid: paid ?? _paid,
      );

  String? get status => _status;

  List<FinancialLog>? get financialLog => _financialLog;

  String? get message => _message;

  String? get count => _count;

  String? get sum => _sum;

  String? get paid => _paid;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['status'] = _status;
    if (_financialLog != null) {
      map['result'] = _financialLog?.map((v) => v.toJson()).toList();
    }
    map['message'] = _message;
    map['count'] = _count;
    map['sum'] = _sum;
    map['paid'] = _paid;
    return map;
  }
}

FinancialLog financialLogFromJson(String str) =>
    FinancialLog.fromJson(json.decode(str));

String financialLogToJson(FinancialLog data) => json.encode(data.toJson());

class FinancialLog {
  FinancialLog({
    num? active,
    String? orderid,
    num? commission,
    String? distance,
    String? id,
    String? createdDate,
  }) {
    _active = active;
    _orderid = orderid;
    _commission = commission;
    _distance = distance;
    _id = id;
    _createdDate = createdDate;
  }

  FinancialLog.fromJson(dynamic json) {
    _active = json['active'];
    _orderid = json['orderid'];
    _commission = json['commission'];
    _distance = json['distance'].toString();
    _id = json['_id'];
    _createdDate = json['created_date'];
  }

  num? _active;
  String? _orderid;
  num? _commission;
  String? _distance;
  String? _id;
  String? _createdDate;

  FinancialLog copyWith({
    num? active,
    String? orderid,
    num? commission,
    String? distance,
    String? id,
    String? createdDate,
  }) =>
      FinancialLog(
        active: active ?? _active,
        orderid: orderid ?? _orderid,
        commission: commission ?? _commission,
        distance: distance ?? _distance,
        id: id ?? _id,
        createdDate: createdDate ?? _createdDate,
      );

  num? get active => _active;

  String? get orderid => _orderid;

  num? get commission => _commission;

  String? get distance => _distance;

  String? get id => _id;

  String? get createdDate => _createdDate;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['active'] = _active;
    map['orderid'] = _orderid;
    map['commission'] = _commission;
    map['distance'] = _distance;
    map['_id'] = _id;
    map['created_date'] = _createdDate;
    return map;
  }
}
