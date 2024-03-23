import 'dart:convert';
PurchaseInwardListResponse purchaseInwardListResponseFromJson(String str) => PurchaseInwardListResponse.fromJson(json.decode(str));
String purchaseInwardListResponseToJson(PurchaseInwardListResponse data) => json.encode(data.toJson());
class PurchaseInwardListResponse {
  PurchaseInwardListResponse({
      String? status, 
      List<Inward>? inwards,
      num? totalCount,}) {
    _status = status;
    _inwards = inwards;
    _totalCount = totalCount;
  }
  PurchaseInwardListResponse.fromJson(dynamic json) {
    _status = json['status'];
    if (json['result'] != null) {
      _inwards = [];
      json['result'].forEach((v) {
        _inwards?.add(Inward.fromJson(v));
      });
    }
    _totalCount = json['totalCount'];
  }
  String? _status;
  List<Inward>? _inwards;
  num? _totalCount;
PurchaseInwardListResponse copyWith({  String? status,
  List<Inward>? inwards,
  num? totalCount,
}) => PurchaseInwardListResponse(  status: status ?? _status,
  inwards: inwards ?? _inwards,
  totalCount: totalCount ?? _totalCount,
);
  String? get status => _status;
  List<Inward>? get inwards => _inwards;
  num? get totalCount => _totalCount;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['status'] = _status;
    if (_inwards != null) {
      map['result'] = _inwards?.map((v) => v.toJson()).toList();
    }
    map['totalCount'] = _totalCount;
    return map;
  }

}

Inward inwardFromJson(String str) => Inward.fromJson(json.decode(str));
String inwardToJson(Inward data) => json.encode(data.toJson());
class Inward {
  Inward({
      String? poId, 
      String? billNo, 
      String? billDate, 
      String? amount, 
      num? type, 
      String? note, 
      InwardOffice? inwardOffice, 
      dynamic outwardOffice, 
      List<dynamic>? bagNo, 
      String? purchasePrice, 
      num? approved, 
      String? orderStatus, 
      dynamic customerCity, 
      num? source, 
      String? id, 
      num? inwardId,
      String? createdDate, 
      num? v,}){
    _poId = poId;
    _billNo = billNo;
    _billDate = billDate;
    _amount = amount;
    _type = type;
    _note = note;
    _inwardOffice = inwardOffice;
    _outwardOffice = outwardOffice;
    _bagNo = bagNo;
    _purchasePrice = purchasePrice;
    _approved = approved;
    _orderStatus = orderStatus;
    _customerCity = customerCity;
    _source = source;
    _id = id;
    _inwardId = inwardId;
    _createdDate = createdDate;
    _v = v;
}

  Inward.fromJson(dynamic json) {
    _poId = json['po_id'].toString();
    _billNo = json['bill_no'];
    _billDate = json['bill_date'];
    _amount = json['amount'].toString();
    _type = json['type'];
    _note = json['note'];
    _inwardOffice = json['inward_office'] != null ? InwardOffice.fromJson(json['inward_office']) : null;
    _outwardOffice = json['outward_office'];
    if (json['bag_no'] != null) {
      _bagNo = [];
      json['bag_no'].forEach((v) {
        _bagNo?.add(v);
      });
    }
    _purchasePrice = json['purchase_price'];
    _approved = json['approved'];
    _orderStatus = json['order_status'];
    _customerCity = json['customer_city'];
    _source = json['source'];
    _id = json['_id'];
    _inwardId = json['inwardId'];
    _createdDate = json['created_date'];
    _v = json['__v'];
  }
  String? _poId;
  String? _billNo;
  String? _billDate;
  String? _amount;
  num? _type;
  String? _note;
  InwardOffice? _inwardOffice;
  dynamic _outwardOffice;
  List<dynamic>? _bagNo;
  String? _purchasePrice;
  num? _approved;
  String? _orderStatus;
  dynamic _customerCity;
  num? _source;
  String? _id;
  num? _inwardId;
  String? _createdDate;
  num? _v;
Inward copyWith({  String? poId,
  String? billNo,
  String? billDate,
  String? amount,
  num? type,
  String? note,
  InwardOffice? inwardOffice,
  dynamic outwardOffice,
  List<dynamic>? bagNo,
  String? purchasePrice,
  num? approved,
  String? orderStatus,
  dynamic customerCity,
  num? source,
  String? id,
  num? inwardId,
  String? createdDate,
  num? v,
}) => Inward(  poId: poId ?? _poId,
  billNo: billNo ?? _billNo,
  billDate: billDate ?? _billDate,
  amount: amount ?? _amount,
  type: type ?? _type,
  note: note ?? _note,
  inwardOffice: inwardOffice ?? _inwardOffice,
  outwardOffice: outwardOffice ?? _outwardOffice,
  bagNo: bagNo ?? _bagNo,
  purchasePrice: purchasePrice ?? _purchasePrice,
  approved: approved ?? _approved,
  orderStatus: orderStatus ?? _orderStatus,
  customerCity: customerCity ?? _customerCity,
  source: source ?? _source,
  id: id ?? _id,
  inwardId: inwardId ?? _inwardId,
  createdDate: createdDate ?? _createdDate,
  v: v ?? _v,
);
  String? get poId => _poId;
  String? get billNo => _billNo;
  String? get billDate => _billDate;
  String? get amount => _amount;
  num? get type => _type;
  String? get note => _note;
  InwardOffice? get inwardOffice => _inwardOffice;
  dynamic get outwardOffice => _outwardOffice;
  List<dynamic>? get bagNo => _bagNo;
  String? get purchasePrice => _purchasePrice;
  num? get approved => _approved;
  String? get orderStatus => _orderStatus;
  dynamic get customerCity => _customerCity;
  num? get source => _source;
  String? get id => _id;
  num? get inwardId => _inwardId;
  String? get createdDate => _createdDate;
  num? get v => _v;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['po_id'] = _poId;
    map['bill_no'] = _billNo;
    map['bill_date'] = _billDate;
    map['amount'] = _amount;
    map['type'] = _type;
    map['note'] = _note;
    if (_inwardOffice != null) {
      map['inward_office'] = _inwardOffice?.toJson();
    }
    map['outward_office'] = _outwardOffice;
    if (_bagNo != null) {
      map['bag_no'] = _bagNo?.map((v) => v.toJson()).toList();
    }
    map['purchase_price'] = _purchasePrice;
    map['approved'] = _approved;
    map['order_status'] = _orderStatus;
    map['customer_city'] = _customerCity;
    map['source'] = _source;
    map['_id'] = _id;
    map['id'] = _id;
    map['inwardId'] = _inwardId;
    map['created_date'] = _createdDate;
    map['__v'] = _v;
    return map;
  }

}

InwardOffice inwardOfficeFromJson(String str) => InwardOffice.fromJson(json.decode(str));
String inwardOfficeToJson(InwardOffice data) => json.encode(data.toJson());
class InwardOffice {
  InwardOffice({
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

  InwardOffice.fromJson(dynamic json) {
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
InwardOffice copyWith({  Position? position,
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
}) => InwardOffice(  position: position ?? _position,
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

Position positionFromJson(String str) => Position.fromJson(json.decode(str));
String positionToJson(Position data) => json.encode(data.toJson());
class Position {
  Position({
      String? type, 
      List<num>? coordinates,}){
    _type = type;
    _coordinates = coordinates;
}

  Position.fromJson(dynamic json) {
    _type = json['type'];
    _coordinates = json['coordinates'] != null ? json['coordinates'].cast<num>() : [];
  }
  String? _type;
  List<num>? _coordinates;
Position copyWith({  String? type,
  List<num>? coordinates,
}) => Position(  type: type ?? _type,
  coordinates: coordinates ?? _coordinates,
);
  String? get type => _type;
  List<num>? get coordinates => _coordinates;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['type'] = _type;
    map['coordinates'] = _coordinates;
    return map;
  }

}