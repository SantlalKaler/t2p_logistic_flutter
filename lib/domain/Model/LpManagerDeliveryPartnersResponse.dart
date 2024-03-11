import 'dart:convert';

import 'package:t2p_logistic/domain/Model/user/VerifyOtpResponse.dart';
LpManagerDeliveryPartnersResponse lpManagerDeliveryPartnersResponseFromJson(String str) => LpManagerDeliveryPartnersResponse.fromJson(json.decode(str));
String lpManagerDeliveryPartnersResponseToJson(LpManagerDeliveryPartnersResponse data) => json.encode(data.toJson());
class LpManagerDeliveryPartnersResponse {
  LpManagerDeliveryPartnersResponse({
      String? status, 
      Result? result,}){
    _status = status;
    _result = result;
}

  LpManagerDeliveryPartnersResponse.fromJson(dynamic json) {
    _status = json['status'];
    _result = json['result'] != null ? Result.fromJson(json['result']) : null;
  }
  String? _status;
  Result? _result;
LpManagerDeliveryPartnersResponse copyWith({  String? status,
  Result? result,
}) => LpManagerDeliveryPartnersResponse(  status: status ?? _status,
  result: result ?? _result,
);
  String? get status => _status;
  Result? get result => _result;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['status'] = _status;
    if (_result != null) {
      map['result'] = _result?.toJson();
    }
    return map;
  }

}

Result resultFromJson(String str) => Result.fromJson(json.decode(str));
String resultToJson(Result data) => json.encode(data.toJson());
class Result {
  Result({
      List<User>? deliveryPartners,
      String? id,}){
    _deliveryPartners = deliveryPartners;
    _id = id;
}

  Result.fromJson(dynamic json) {
    if (json['delivery_boy'] != null) {
      _deliveryPartners = [];
      json['delivery_boy'].forEach((v) {
        _deliveryPartners?.add(User.fromJson(v));
      });
    }
    _id = json['_id'];
  }
  List<User>? _deliveryPartners;
  String? _id;
Result copyWith({  List<User>? partnerList,
  String? id,
}) => Result(  deliveryPartners: partnerList ?? _deliveryPartners,
  id: id ?? _id,
);
  List<User>? get partnerList => _deliveryPartners;
  String? get id => _id;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (_deliveryPartners != null) {
      map['delivery_boy'] = _deliveryPartners?.map((v) => v.toJson()).toList();
    }
    map['_id'] = _id;
    return map;
  }

}