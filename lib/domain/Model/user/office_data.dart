

import 'dart:convert';

import 'AddressListResponse.dart';

OfficeData officeDataFromJson(String str) => OfficeData.fromJson(json.decode(str));
String officeDataToJson(OfficeData data) => json.encode(data.toJson());
class OfficeData {
  OfficeData({
    Position? position,
    String? name,
    String? address,
    String? contactPerson,
    String? contactPersonEmail,
    String? contactPersonMobile,
    String? createdDate,
    String? updateDate,
    num? active,
    num? deleted,
    List<dynamic>? bagNo,
    String? completeAddress,
    String? id,
    String? city,
    num? v,}){
    _position = position;
    _name = name;
    _address = address;
    _contactPerson = contactPerson;
    _contactPersonEmail = contactPersonEmail;
    _contactPersonMobile = contactPersonMobile;
    _createdDate = createdDate;
    _updateDate = updateDate;
    _active = active;
    _deleted = deleted;
    _bagNo = bagNo;
    _completeAddress = completeAddress;
    _id = id;
    _city = city;
    _v = v;
  }

  OfficeData.fromJson(dynamic json) {
    _position = json['position'] != null ? Position.fromJson(json['position']) : null;
    _name = json['name'];
    _address = json['address'];
    _contactPerson = json['contact_person'];
    _contactPersonEmail = json['contact_person_email'];
    _contactPersonMobile = json['contact_person_mobile'];
    _createdDate = json['created_date'];
    _updateDate = json['update_date'];
    _active = json['active'];
    _deleted = json['deleted'];
    if (json['bag_no'] != null) {
      _bagNo = [];
      json['bag_no'].forEach((v) {
        _bagNo?.add(v);
      });
    }
    _completeAddress = json['complete_address'];
    _id = json['_id'];
    _city = json['city'];
    _v = json['__v'];
  }
  Position? _position;
  String? _name;
  String? _address;
  String? _contactPerson;
  String? _contactPersonEmail;
  String? _contactPersonMobile;
  String? _createdDate;
  String? _updateDate;
  num? _active;
  num? _deleted;
  List<dynamic>? _bagNo;
  String? _completeAddress;
  String? _id;
  String? _city;
  num? _v;
  OfficeData copyWith({  Position? position,
    String? name,
    String? address,
    String? contactPerson,
    String? contactPersonEmail,
    String? contactPersonMobile,
    String? createdDate,
    String? updateDate,
    num? active,
    num? deleted,
    List<dynamic>? bagNo,
    String? completeAddress,
    String? id,
    String? city,
    num? v,
  }) => OfficeData(  position: position ?? _position,
    name: name ?? _name,
    address: address ?? _address,
    contactPerson: contactPerson ?? _contactPerson,
    contactPersonEmail: contactPersonEmail ?? _contactPersonEmail,
    contactPersonMobile: contactPersonMobile ?? _contactPersonMobile,
    createdDate: createdDate ?? _createdDate,
    updateDate: updateDate ?? _updateDate,
    active: active ?? _active,
    deleted: deleted ?? _deleted,
    bagNo: bagNo ?? _bagNo,
    completeAddress: completeAddress ?? _completeAddress,
    id: id ?? _id,
    city: city ?? _city,
    v: v ?? _v,
  );
  Position? get position => _position;
  String? get name => _name;
  String? get address => _address;
  String? get contactPerson => _contactPerson;
  String? get contactPersonEmail => _contactPersonEmail;
  String? get contactPersonMobile => _contactPersonMobile;
  String? get createdDate => _createdDate;
  String? get updateDate => _updateDate;
  num? get active => _active;
  num? get deleted => _deleted;
  List<dynamic>? get bagNo => _bagNo;
  String? get completeAddress => _completeAddress;
  String? get id => _id;
  String? get city => _city;
  num? get v => _v;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (_position != null) {
      map['position'] = _position?.toJson();
    }
    map['name'] = _name;
    map['address'] = _address;
    map['contact_person'] = _contactPerson;
    map['contact_person_email'] = _contactPersonEmail;
    map['contact_person_mobile'] = _contactPersonMobile;
    map['created_date'] = _createdDate;
    map['update_date'] = _updateDate;
    map['active'] = _active;
    map['deleted'] = _deleted;
    if (_bagNo != null) {
      map['bag_no'] = _bagNo?.map((v) => v.toJson()).toList();
    }
    map['complete_address'] = _completeAddress;
    map['_id'] = _id;
    map['city'] = _city;
    map['__v'] = _v;
    return map;
  }

}