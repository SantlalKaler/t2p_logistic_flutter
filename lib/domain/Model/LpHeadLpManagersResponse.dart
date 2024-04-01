import 'dart:convert';

import 'package:t2p_logistic/domain/Model/user/VerifyOtpResponse.dart';

import 'user/user.dart';
LpHeadLpManagersResponse lpHeadLpManagersResponseFromJson(String str) => LpHeadLpManagersResponse.fromJson(json.decode(str));
String lpHeadLpManagersResponseToJson(LpHeadLpManagersResponse data) => json.encode(data.toJson());
class LpHeadLpManagersResponse {
  LpHeadLpManagersResponse({
      String? status, 
      Result? result,}){
    _status = status;
    _result = result;
}

  LpHeadLpManagersResponse.fromJson(dynamic json) {
    _status = json['status'];
    _result = json['result'] != null ? Result.fromJson(json['result']) : null;
  }
  String? _status;
  Result? _result;
LpHeadLpManagersResponse copyWith({  String? status,
  Result? result,
}) => LpHeadLpManagersResponse(  status: status ?? _status,
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
      List<User>? lpManager,
      String? id,}){
    _lpManager = lpManager;
    _id = id;
}

  Result.fromJson(dynamic json) {
    if (json['lp_manager'] != null) {
      _lpManager = [];
      json['lp_manager'].forEach((v) {
        _lpManager?.add(User.fromJson(v));
      });
    }
    _id = json['_id'];
  }
  List<User>? _lpManager;
  String? _id;
Result copyWith({  List<User>? lpManager,
  String? id,
}) => Result(  lpManager: lpManager ?? _lpManager,
  id: id ?? _id,
);
  List<User>? get lpManager => _lpManager;
  String? get id => _id;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (_lpManager != null) {
      map['lp_manager'] = _lpManager?.map((v) => v.toJson()).toList();
    }
    map['_id'] = _id;
    return map;
  }

}
