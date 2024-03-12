import 'dart:convert';
AddressListResponse addressListResponseFromJson(String str) => AddressListResponse.fromJson(json.decode(str));
String addressListResponseToJson(AddressListResponse data) => json.encode(data.toJson());
class AddressListResponse {
  AddressListResponse({
      String? status, 
      String? message, 
      List<Address>? address,}){
    _status = status;
    _message = message;
    _address = address;
}

  AddressListResponse.fromJson(dynamic json) {
    _status = json['status'];
    _message = json['message'];
    if (json['result'] != null) {
      _address = [];
      json['result'].forEach((v) {
        _address?.add(Address.fromJson(v));
      });
    }
  }
  String? _status;
  String? _message;
  List<Address>? _address;
AddressListResponse copyWith({  String? status,
  String? message,
  List<Address>? address,
}) => AddressListResponse(  status: status ?? _status,
  message: message ?? _message,
  address: address ?? _address,
);
  String? get status => _status;
  String? get message => _message;
  List<Address>? get address => _address;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['status'] = _status;
    map['message'] = _message;
    if (_address != null) {
      map['result'] = _address?.map((v) => v.toJson()).toList();
    }
    return map;
  }

}

Address addressFromJson(String str) => Address.fromJson(json.decode(str));
String addressToJson(Address data) => json.encode(data.toJson());
class Address {
  Address({
      Position? position, 
      String? user, 
      String? title, 
      String? address, 
      String? address2, 
      String? postOffice, 
      String? pincode, 
      String? contactName, 
      String? contactMobile, 
      num? deleted, 
      String? updateDate, 
      String? landmark, 
      String? id, 
      City? city, 
      State? state, 
      String? createdDate, 
      num? v,}){
    _position = position;
    _user = user;
    _title = title;
    _address = address;
    _address2 = address2;
    _postOffice = postOffice;
    _pincode = pincode;
    _contactName = contactName;
    _contactMobile = contactMobile;
    _deleted = deleted;
    _updateDate = updateDate;
    _landmark = landmark;
    _id = id;
    _city = city;
    _state = state;
    _createdDate = createdDate;
    _v = v;
}

  Address.fromJson(dynamic json) {
    _position = json ['position'] != null ? Position.fromJson(json['position']) : null;
    _user = json['user'];
    _title = json['title'];
    _address = json['address'];
    _address2 = json['address2'];
    _postOffice = json['post_office'];
    _pincode = json['pincode'];
    _contactName = json['contact_name'];
    _contactMobile = json['contact_mobile'];
    _deleted = json['deleted'];
    _updateDate = json['update_date'];
    _landmark = json['landmark'];
    _id = json['_id'];
    _city = json['city'] != null ? City.fromJson(json['city']) : null;
    _state = json['state'] != null ? State.fromJson(json['state']) : null;
    _createdDate = json['created_date'];
    _v = json['__v'];
  }
  Position? _position;
  String? _user;
  String? _title;
  String? _address;
  String? _address2;
  String? _postOffice;
  String? _pincode;
  String? _contactName;
  String? _contactMobile;
  num? _deleted;
  String? _updateDate;
  String? _landmark;
  String? _id;
  City? _city;
  State? _state;
  String? _createdDate;
  num? _v;
Address copyWith({  Position? position,
  String? user,
  String? title,
  String? address,
  String? address2,
  String? postOffice,
  String? pincode,
  String? contactName,
  String? contactMobile,
  num? deleted,
  String? updateDate,
  String? landmark,
  String? id,
  City? city,
  State? state,
  String? createdDate,
  num? v,
}) => Address(  position: position ?? _position,
  user: user ?? _user,
  title: title ?? _title,
  address: address ?? _address,
  address2: address2 ?? _address2,
  postOffice: postOffice ?? _postOffice,
  pincode: pincode ?? _pincode,
  contactName: contactName ?? _contactName,
  contactMobile: contactMobile ?? _contactMobile,
  deleted: deleted ?? _deleted,
  updateDate: updateDate ?? _updateDate,
  landmark: landmark ?? _landmark,
  id: id ?? _id,
  city: city ?? _city,
  state: state ?? _state,
  createdDate: createdDate ?? _createdDate,
  v: v ?? _v,
);
  Position? get position => _position;
  String? get user => _user;
  String? get title => _title;
  String? get address => _address;
  String? get address2 => _address2;
  String? get postOffice => _postOffice;
  String? get pincode => _pincode;
  String? get contactName => _contactName;
  String? get contactMobile => _contactMobile;
  num? get deleted => _deleted;
  String? get updateDate => _updateDate;
  String? get landmark => _landmark;
  String? get id => _id;
  City? get city => _city;
  State? get state => _state;
  String? get createdDate => _createdDate;
  num? get v => _v;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (_position != null) {
      map['position'] = _position?.toJson();
    }
    map['user'] = _user;
    map['title'] = _title;
    map['address'] = _address;
    map['address2'] = _address2;
    map['post_office'] = _postOffice;
    map['pincode'] = _pincode;
    map['contact_name'] = _contactName;
    map['contact_mobile'] = _contactMobile;
    map['deleted'] = _deleted;
    map['update_date'] = _updateDate;
    map['landmark'] = _landmark;
    map['_id'] = _id;
    if (_city != null) {
      map['city'] = _city?.toJson();
    }
    if (_state != null) {
      map['state'] = _state?.toJson();
    }
    map['created_date'] = _createdDate;
    map['__v'] = _v;
    return map;
  }
}

State stateFromJson(String str) => State.fromJson(json.decode(str));
String stateToJson(State data) => json.encode(data.toJson());
class State {
  State({
      String? id, 
      String? name,}){
    _id = id;
    _name = name;
}

  State.fromJson(dynamic json) {
    _id = json['_id'].toString();
    _name = json['name'];
  }
  String? _id;
  String? _name;
State copyWith({  String? id,
  String? name,
}) => State(  id: id ?? _id,
  name: name ?? _name,
);
  String? get id => _id;
  String? get name => _name;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['_id'] = _id;
    map['name'] = _name;
    return map;
  }

}

City cityFromJson(String str) => City.fromJson(json.decode(str));
String cityToJson(City data) => json.encode(data.toJson());
class City {
  City({
      String? name, 
      String? id,}){
    _name = name;
    _id = id;
}

  City.fromJson(dynamic json) {
    _name = json['name'];
    _id = json['_id'];
  }
  String? _name;
  String? _id;
City copyWith({  String? name,
  String? id,
}) => City(  name: name ?? _name,
  id: id ?? _id,
);
  String? get name => _name;
  String? get id => _id;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['name'] = _name;
    map['_id'] = _id;
    return map;
  }

}

Position positionFromJson(String str) => Position.fromJson(json.decode(str));
String positionToJson(Position data) => json.encode(data.toJson());
class Position {
  Position({
      String? type, 
      List<double>? coordinates,}){
    _type = type;
    _coordinates = coordinates;
}

  Position.fromJson(dynamic json) {
    _type = json['type'];
    _coordinates = json['coordinates'] != null ? json['coordinates'].cast<double>() : [];
  }
  String? _type;
  List<double>? _coordinates;
Position copyWith({  String? type,
  List<double>? coordinates,
}) => Position(  type: type ?? _type,
  coordinates: coordinates ?? _coordinates,
);
  String? get type => _type;
  List<double>? get coordinates => _coordinates;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['type'] = _type;
    map['coordinates'] = _coordinates;
    return map;
  }

}