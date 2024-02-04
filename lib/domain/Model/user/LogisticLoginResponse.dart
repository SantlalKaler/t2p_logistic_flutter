import 'dart:convert';
LogisticLoginResponse logisticLoginResponseFromJson(String str) => LogisticLoginResponse.fromJson(json.decode(str));
String logisticLoginResponseToJson(LogisticLoginResponse data) => json.encode(data.toJson());
class LogisticLoginResponse {
  LogisticLoginResponse({
      String? status, 
      num? otp, 
      String? message,}){
    _status = status;
    _otp = otp;
    _message = message;
}

  LogisticLoginResponse.fromJson(dynamic json) {
    _status = json['status'];
    _otp = json['OTP'];
    _message = json['message'];
  }
  String? _status;
  num? _otp;
  String? _message;
LogisticLoginResponse copyWith({  String? status,
  num? otp,
  String? message,
}) => LogisticLoginResponse(  status: status ?? _status,
  otp: otp ?? _otp,
  message: message ?? _message,
);
  String? get status => _status;
  num? get otp => _otp;
  String? get message => _message;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['status'] = _status;
    map['OTP'] = _otp;
    map['message'] = _message;
    return map;
  }

}