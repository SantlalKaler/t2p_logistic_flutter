import 'dart:convert';

import 'package:t2p_logistic/domain/Model/user/VerifyOtpResponse.dart';

import '../user/user.dart';
LogisticBoyListResponse logisticBoyListResponseFromJson(String str) => LogisticBoyListResponse.fromJson(json.decode(str));
String logisticBoyListResponseToJson(LogisticBoyListResponse data) => json.encode(data.toJson());
class LogisticBoyListResponse {
  LogisticBoyListResponse({
      String? status, 
      List<User>? user,
      String? message,}){
    _status = status;
    _user = user;
    _message = message;
}

  LogisticBoyListResponse.fromJson(dynamic json) {
    _status = json['status'];
    if (json['result'] != null) {
      _user = [];
      json['result'].forEach((v) {
        _user?.add(User.fromJson(v));
      });
    }
    _message = json['message'];
  }
  String? _status;
  List<User>? _user;
  String? _message;
LogisticBoyListResponse copyWith({  String? status,
  List<User>? user,
  String? message,
}) => LogisticBoyListResponse(  status: status ?? _status,
  user: user ?? _user,
  message: message ?? _message,
);
  String? get status => _status;
  List<User>? get user => _user;
  String? get message => _message;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['status'] = _status;
    if (_user != null) {
      map['result'] = _user?.map((v) => v.toJson()).toList();
    }
    map['message'] = _message;
    return map;
  }

}
