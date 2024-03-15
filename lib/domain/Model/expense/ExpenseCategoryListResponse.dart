import 'dart:convert';

ExpenseCatSubCatListResponse expenseCatSubCatListResponseFromJson(String str) =>
    ExpenseCatSubCatListResponse.fromJson(json.decode(str));

String expenseCatSubCatListResponseToJson(ExpenseCatSubCatListResponse data) =>
    json.encode(data.toJson());

class ExpenseCatSubCatListResponse {
  ExpenseCatSubCatListResponse({
    String? status,
    List<CatSubCatCommon>? result,
  }) {
    _status = status;
    _result = result;
  }

  ExpenseCatSubCatListResponse.fromJson(dynamic json) {
    _status = json['status'];
    if (json['result'] != null) {
      _result = [];
      json['result'].forEach((v) {
        _result?.add(CatSubCatCommon.fromJson(v));
      });
    }
  }

  String? _status;
  List<CatSubCatCommon>? _result;

  ExpenseCatSubCatListResponse copyWith({
    String? status,
    List<CatSubCatCommon>? result,
  }) =>
      ExpenseCatSubCatListResponse(
        status: status ?? _status,
        result: result ?? _result,
      );

  String? get status => _status;

  List<CatSubCatCommon>? get result => _result;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['status'] = _status;
    if (_result != null) {
      map['result'] = _result?.map((v) => v.toJson()).toList();
    }
    return map;
  }
}

CatSubCatCommon catSubCatCommonFromJson(String str) => CatSubCatCommon.fromJson(json.decode(str));

String catSubCatCommonToJson(CatSubCatCommon data) => json.encode(data.toJson());

class CatSubCatCommon {
  CatSubCatCommon({
    String? name,
    String? description,
    dynamic parent,
    num? active,
    num? deleted,
    String? id,
    num? v,
  }) {
    _name = name;
    _description = description;
    _parent = parent;
    _active = active;
    _deleted = deleted;
    _id = id;
    _v = v;
  }

  CatSubCatCommon.fromJson(dynamic json) {
    _name = json['name'];
    _description = json['description'];
    _parent = json['parent'];
    _active = json['active'];
    _deleted = json['deleted'];
    _id = json['_id'];
    _v = json['__v'];
  }

  String? _name;
  String? _description;
  dynamic _parent;
  num? _active;
  num? _deleted;
  String? _id;
  num? _v;

  CatSubCatCommon copyWith({
    String? name,
    String? description,
    dynamic parent,
    num? active,
    num? deleted,
    String? id,
    num? v,
  }) =>
      CatSubCatCommon(
        name: name ?? _name,
        description: description ?? _description,
        parent: parent ?? _parent,
        active: active ?? _active,
        deleted: deleted ?? _deleted,
        id: id ?? _id,
        v: v ?? _v,
      );

  String? get name => _name;

  String? get description => _description;

  dynamic get parent => _parent;

  num? get active => _active;

  num? get deleted => _deleted;

  String? get id => _id;

  num? get v => _v;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['name'] = _name;
    map['description'] = _description;
    map['parent'] = _parent;
    map['active'] = _active;
    map['deleted'] = _deleted;
    map['_id'] = _id;
    map['__v'] = _v;
    return map;
  }
}
