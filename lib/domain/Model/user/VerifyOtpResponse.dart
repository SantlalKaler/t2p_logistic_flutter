import 'dart:convert';

import 'package:t2p_logistic/domain/Model/user/user.dart';

import 'AddressListResponse.dart';
import 'office_data.dart';
VerifyOtpResponse verifyOtpResponseFromJson(String str) => VerifyOtpResponse.fromJson(json.decode(str));
String verifyOtpResponseToJson(VerifyOtpResponse data) => json.encode(data.toJson());
class VerifyOtpResponse {
  VerifyOtpResponse({
      String? status, 
      User? result,
      OfficeData? officeData, 
      String? message,}){
    _status = status;
    _result = result;
    _officeData = officeData;
    _message = message;
}

  VerifyOtpResponse.fromJson(dynamic json) {
    _status = json['status'];
    _result = json['result'] != null ? User.fromJson(json['result']) : null;
    _officeData = json['office_data'] != null ? OfficeData.fromJson(json['office_data']) : null;
    _message = json['message'];
  }
  String? _status;
  User? _result;
  OfficeData? _officeData;
  String? _message;
VerifyOtpResponse copyWith({  String? status,
  User? result,
  OfficeData? officeData,
  String? message,
}) => VerifyOtpResponse(  status: status ?? _status,
  result: result ?? _result,
  officeData: officeData ?? _officeData,
  message: message ?? _message,
);
  String? get status => _status;
  User? get result => _result;
  OfficeData? get officeData => _officeData;
  String? get message => _message;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['status'] = _status;
    if (_result != null) {
      map['result'] = _result?.toJson();
    }
    if (_officeData != null) {
      map['office_data'] = _officeData?.toJson();
    }
    map['message'] = _message;
    return map;
  }

}