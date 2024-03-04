import 'dart:convert';

import 'package:t2p_logistic/domain/Model/user/AddressListResponse.dart';
import 'package:t2p_logistic/domain/Model/user/VerifyOtpResponse.dart';

import 'T2POrderResponse.dart';
Af2apOrderResponse af2apOrderResponseFromJson(String str) => Af2apOrderResponse.fromJson(json.decode(str));
String af2apOrderResponseToJson(Af2apOrderResponse data) => json.encode(data.toJson());
class Af2apOrderResponse {
  Af2apOrderResponse({
      String? status, 
      List<AF2APOrder>? order,
      num? totalCount,}){
    _status = status;
    _order = order;
    _totalCount = totalCount;
}

  Af2apOrderResponse.fromJson(dynamic json) {
    _status = json['status'];
    if (json['result'] != null) {
      _order = [];
      json['result'].forEach((v) {
        _order?.add(AF2APOrder.fromJson(v));
      });
    }
    _totalCount = json['totalCount'];
  }
  String? _status;
  List<AF2APOrder>? _order;
  num? _totalCount;
Af2apOrderResponse copyWith({  String? status,
  List<AF2APOrder>? order,
  num? totalCount,
}) => Af2apOrderResponse(  status: status ?? _status,
  order: order ?? _order,
  totalCount: totalCount ?? _totalCount,
);
  String? get status => _status;
  List<AF2APOrder>? get order => _order;
  num? get totalCount => _totalCount;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['status'] = _status;
    if (_order != null) {
      map['result'] = _order?.map((v) => v.toJson()).toList();
    }
    map['totalCount'] = _totalCount;
    return map;
  }

}

AF2APOrder aF2APOrderFromJson(String str) => AF2APOrder.fromJson(json.decode(str));
String aF2APOrderToJson(AF2APOrder data) => json.encode(data.toJson());
class AF2APOrder {
  AF2APOrder({
      String? orderid, 
      User? user, 
      String? remarks, 
      String? pickupDate, 
      String? pickupTime, 
      String? deliveryType, 
      String? deliveryDate, 
      String? deliveryTimeslot, 
      num? active, 
      num? deleted, 
      String? totalPrice, 
      String? duesAmount,
      String? paidAmount,
      String? shippingPrice,
      String? pickupPrice, 
      String? deliveryPrice, 
      String? pickupDistance, 
      String? deliveryDistance, 
      String? totalWeight,
    User? lpManager,
      String? status, 
      num? orderConfirmation,
    User? pickupPartner,
      User? pickupBoy,
      DeliveryPartner? deliveryPartner, 
      User? deliveryBoy,
      String? sgst, 
      String? igst, 
      String? cgst, 
      String? id, 
      Address? sourceLocation,
      Address? destinationLocation,
      List<Products>? products, 
      String? createdAt, 
      String? updatedAt, 
      num? v,}){
    _orderid = orderid;
    _user = user;
    _remarks = remarks;
    _pickupDate = pickupDate;
    _pickupTime = pickupTime;
    _deliveryType = deliveryType;
    _lpManager = lpManager;
    _deliveryDate = deliveryDate;
    _deliveryTimeslot = deliveryTimeslot;
    _active = active;
    _deleted = deleted;
    _totalPrice = totalPrice;
    _paidAmount = paidAmount;
    _duesAmount = duesAmount;
    _shippingPrice = shippingPrice;
    _pickupPrice = pickupPrice;
    _deliveryPrice = deliveryPrice;
    _pickupDistance = pickupDistance;
    _deliveryDistance = deliveryDistance;
    _totalWeight = totalWeight;
    _status = status;
    _orderConfirmation = orderConfirmation;
    _pickupPartner = pickupPartner;
    _pickupBoy = pickupBoy;
    _deliveryPartner = deliveryPartner;
    _deliveryBoy = deliveryBoy;
    _sgst = sgst;
    _igst = igst;
    _cgst = cgst;
    _id = id;
    _sourceLocation = sourceLocation;
    _destinationLocation = destinationLocation;
    _products = products;
    _createdAt = createdAt;
    _updatedAt = updatedAt;
    _v = v;
}

  AF2APOrder.fromJson(dynamic json) {
    _orderid = json['orderid'];
    _user = json['user'] != null ? User.fromJson(json['user']) : null;
    _remarks = json['remarks'];
    _pickupDate = json['pickup_date'];
    _pickupTime = json['pickup_time'];
    _deliveryType = json['delivery_type'];
    _deliveryDate = json['delivery_date'];
    _deliveryTimeslot = json['delivery_timeslot'];
    _active = json['active'];
    _deleted = json['deleted'];
    _totalPrice = json['total_price'];
    _paidAmount = json['paid_amount'].toString();
    _duesAmount = json['dues_amount'].toString();
    _shippingPrice = json['shipping_price'];
    _pickupPrice = json['pickup_price'];
    _deliveryPrice = json['delivery_price'];
    _pickupDistance = json['pickup_distance'];
    _deliveryDistance = json['delivery_distance'];
    _totalWeight = json['total_weight'];
    _status = json['status'];
    _orderConfirmation = json['order_confirmation'];
    _pickupPartner = json['pickup_partner'] != null ? User.fromJson(json['pickup_partner']) : null;
    _lpManager = json['lp_manager'] != null ? User.fromJson(json['lp_manager']) : null;
    _pickupBoy = json['pickup_boy'] != null ? User.fromJson(json['pickup_boy']) : null;
    _deliveryPartner = json['delivery_partner'] != null ? DeliveryPartner.fromJson(json['delivery_partner']) : null;
    _deliveryBoy = json['delivery_boy'] != null ? User.fromJson(json['delivery_boy']) : null;
    _sgst = json['sgst'];
    _igst = json['igst'];
    _cgst = json['cgst'];
    _id = json['_id'];
    _sourceLocation = json['source_location'] != null ? Address.fromJson(json['source_location']) : null;
    _destinationLocation = json['destination_location'] != null ? Address.fromJson(json['destination_location']) : null;
    if (json['products'] != null) {
      _products = [];
      json['products'].forEach((v) {
        _products?.add(Products.fromJson(v));
      });
    }
    _createdAt = json['createdAt'];
    _updatedAt = json['updatedAt'];
    _v = json['__v'];
  }
  String? _orderid;
  User? _user;
  String? _remarks;
  String? _pickupDate;
  String? _pickupTime;
  User? _lpManager;
  String? _deliveryType;
  String? _deliveryDate;
  String? _deliveryTimeslot;
  num? _active;
  num? _deleted;
  String? _totalPrice;
  String? _paidAmount;
  String? _duesAmount;
  String? _shippingPrice;
  String? _pickupPrice;
  String? _deliveryPrice;
  String? _pickupDistance;
  String? _deliveryDistance;
  String? _totalWeight;
  String? _status;
  num? _orderConfirmation;
  User? _pickupPartner;
  User? _pickupBoy;
  DeliveryPartner? _deliveryPartner;
  User? _deliveryBoy;
  String? _sgst;
  String? _igst;
  String? _cgst;
  String? _id;
  Address? _sourceLocation;
  Address? _destinationLocation;
  List<Products>? _products;
  String? _createdAt;
  String? _updatedAt;
  num? _v;
AF2APOrder copyWith({  String? orderid,
  User? user,
  String? remarks,
  String? pickupDate,
  User? lpManager,
  String? pickupTime,
  String? deliveryType,
  String? deliveryDate,
  String? deliveryTimeslot,
  num? active,
  num? deleted,
  String? totalPrice,
  String? paidAmount,
  String? duesAmount,
  String? shippingPrice,
  String? pickupPrice,
  String? deliveryPrice,
  String? pickupDistance,
  String? deliveryDistance,
  String? totalWeight,
  String? status,
  num? orderConfirmation,
  User? pickupPartner,
  dynamic pickupBoy,
  DeliveryPartner? deliveryPartner,
  dynamic deliveryBoy,
  String? sgst,
  String? igst,
  String? cgst,
  String? id,
  Address? sourceLocation,
  Address? destinationLocation,
  List<Products>? products,
  String? createdAt,
  String? updatedAt,
  num? v,
}) => AF2APOrder(  orderid: orderid ?? _orderid,
  user: user ?? _user,
  remarks: remarks ?? _remarks,
  pickupDate: pickupDate ?? _pickupDate,
  pickupTime: pickupTime ?? _pickupTime,
  lpManager: lpManager ?? _lpManager,
  deliveryType: deliveryType ?? _deliveryType,
  deliveryDate: deliveryDate ?? _deliveryDate,
  deliveryTimeslot: deliveryTimeslot ?? _deliveryTimeslot,
  active: active ?? _active,
  deleted: deleted ?? _deleted,
  totalPrice: totalPrice ?? _totalPrice,
  paidAmount: paidAmount ?? _paidAmount,
  duesAmount: duesAmount ?? _duesAmount,
  shippingPrice: shippingPrice ?? _shippingPrice,
  pickupPrice: pickupPrice ?? _pickupPrice,
  deliveryPrice: deliveryPrice ?? _deliveryPrice,
  pickupDistance: pickupDistance ?? _pickupDistance,
  deliveryDistance: deliveryDistance ?? _deliveryDistance,
  totalWeight: totalWeight ?? _totalWeight,
  status: status ?? _status,
  orderConfirmation: orderConfirmation ?? _orderConfirmation,
  pickupPartner: pickupPartner ?? _pickupPartner,
  pickupBoy: pickupBoy ?? _pickupBoy,
  deliveryPartner: deliveryPartner ?? _deliveryPartner,
  deliveryBoy: deliveryBoy ?? _deliveryBoy,
  sgst: sgst ?? _sgst,
  igst: igst ?? _igst,
  cgst: cgst ?? _cgst,
  id: id ?? _id,
  sourceLocation: sourceLocation ?? _sourceLocation,
  destinationLocation: destinationLocation ?? _destinationLocation,
  products: products ?? _products,
  createdAt: createdAt ?? _createdAt,
  updatedAt: updatedAt ?? _updatedAt,
  v: v ?? _v,
);
  String? get orderid => _orderid;
  User? get user => _user;
  String? get remarks => _remarks;
  String? get pickupDate => _pickupDate;
  User? get lpManager => _lpManager;
  String? get pickupTime => _pickupTime;
  String? get deliveryType => _deliveryType;
  String? get deliveryDate => _deliveryDate;
  String? get deliveryTimeslot => _deliveryTimeslot;
  num? get active => _active;
  num? get deleted => _deleted;
  String? get totalPrice => _totalPrice;
  String? get paidAmount => _paidAmount;
  String? get duesAmount => _duesAmount;
  String? get shippingPrice => _shippingPrice;
  String? get pickupPrice => _pickupPrice;
  String? get deliveryPrice => _deliveryPrice;
  String? get pickupDistance => _pickupDistance;
  String? get deliveryDistance => _deliveryDistance;
  String? get totalWeight => _totalWeight;
  String? get status => _status;
  num? get orderConfirmation => _orderConfirmation;
  User? get pickupPartner => _pickupPartner;
  User? get pickupBoy => _pickupBoy;
  DeliveryPartner? get deliveryPartner => _deliveryPartner;
  User? get deliveryBoy => _deliveryBoy;
  String? get sgst => _sgst;
  String? get igst => _igst;
  String? get cgst => _cgst;
  String? get id => _id;
  Address? get sourceLocation => _sourceLocation;
  Address? get destinationLocation => _destinationLocation;
  List<Products>? get products => _products;
  String? get createdAt => _createdAt;
  String? get updatedAt => _updatedAt;
  num? get v => _v;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['orderid'] = _orderid;
    if (_user != null) {
      map['user'] = _user?.toJson();
    }
    map['remarks'] = _remarks;
    map['pickup_date'] = _pickupDate;
    map['pickup_time'] = _pickupTime;
    map['delivery_type'] = _deliveryType;
    map['delivery_timeslot'] = _deliveryTimeslot;
    map['lp_manager'] = _lpManager;
    map['active'] = _active;
    map['deleted'] = _deleted;
    map['total_price'] = _totalPrice;
    map['paid_amount'] = _paidAmount;
    map['dues_amount'] = _duesAmount;
    map['shipping_price'] = _shippingPrice;
    map['pickup_price'] = _pickupPrice;
    map['delivery_price'] = _deliveryPrice;
    map['pickup_distance'] = _pickupDistance;
    map['delivery_distance'] = _deliveryDistance;
    map['total_weight'] = _totalWeight;
    map['status'] = _status;
    map['order_confirmation'] = _orderConfirmation;
    if (_pickupPartner != null) {
      map['pickup_partner'] = _pickupPartner?.toJson();
    }
    if (_lpManager != null) {
      map['lp_manager'] = _lpManager?.toJson();
    }
    if (_pickupBoy != null) {
      map['pickup_boy'] = _pickupBoy?.toJson();
    }
    if (_deliveryPartner != null) {
      map['delivery_partner'] = _deliveryPartner?.toJson();
    }
    if (_deliveryBoy != null) {
      map['delivery_boy'] = _deliveryBoy?.toJson();
    }
    map['sgst'] = _sgst;
    map['igst'] = _igst;
    map['cgst'] = _cgst;
    map['_id'] = _id;
    if (_sourceLocation != null) {
      map['source_location'] = _sourceLocation?.toJson();
    }
    if (_destinationLocation != null) {
      map['destination_location'] = _destinationLocation?.toJson();
    }
    if (_products != null) {
      map['products'] = _products?.map((v) => v.toJson()).toList();
    }
    map['createdAt'] = _createdAt;
    map['updatedAt'] = _updatedAt;
    map['__v'] = _v;
    return map;
  }

}

Products productsFromJson(String str) => Products.fromJson(json.decode(str));
String productsToJson(Products data) => json.encode(data.toJson());
class Products {
  Products({
      String? name, 
      String? weight, 
      String? height, 
      String? weidth, 
      String? length, 
      String? id, 
      Category? category, 
      SubCategory? subCategory,}){
    _name = name;
    _weight = weight;
    _height = height;
    _weidth = weidth;
    _length = length;
    _id = id;
    _category = category;
    _subCategory = subCategory;
}

  Products.fromJson(dynamic json) {
    _name = json['name'];
    _weight = json['weight'];
    _height = json['height'];
    _weidth = json['weidth'];
    _length = json['length'];
    _id = json['_id'];
    _category = json['category'] != null ? Category.fromJson(json['category']) : null;
    _subCategory = json['sub_category'] != null ? SubCategory.fromJson(json['sub_category']) : null;
  }
  String? _name;
  String? _weight;
  String? _height;
  String? _weidth;
  String? _length;
  String? _id;
  Category? _category;
  SubCategory? _subCategory;
Products copyWith({  String? name,
  String? weight,
  String? height,
  String? weidth,
  String? length,
  String? id,
  Category? category,
  SubCategory? subCategory,
}) => Products(  name: name ?? _name,
  weight: weight ?? _weight,
  height: height ?? _height,
  weidth: weidth ?? _weidth,
  length: length ?? _length,
  id: id ?? _id,
  category: category ?? _category,
  subCategory: subCategory ?? _subCategory,
);
  String? get name => _name;
  String? get weight => _weight;
  String? get height => _height;
  String? get weidth => _weidth;
  String? get length => _length;
  String? get id => _id;
  Category? get category => _category;
  SubCategory? get subCategory => _subCategory;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['name'] = _name;
    map['weight'] = _weight;
    map['height'] = _height;
    map['weidth'] = _weidth;
    map['length'] = _length;
    map['_id'] = _id;
    if (_category != null) {
      map['category'] = _category?.toJson();
    }
    if (_subCategory != null) {
      map['sub_category'] = _subCategory?.toJson();
    }
    return map;
  }

}

SubCategory subCategoryFromJson(String str) => SubCategory.fromJson(json.decode(str));
String subCategoryToJson(SubCategory data) => json.encode(data.toJson());
class SubCategory {
  SubCategory({
      String? name, 
      String? description, 
      String? descriptionAfterContent, 
      String? parent, 
      String? file, 
      String? createdDate, 
      String? updateDate, 
      num? active, 
      num? deleted, 
      String? seoTitle, 
      String? seoDescription, 
      String? seoKeywords, 
      String? additionalCost, 
      List<String>? slugHistory, 
      String? id, 
      String? slug, 
      num? v,}){
    _name = name;
    _description = description;
    _descriptionAfterContent = descriptionAfterContent;
    _parent = parent;
    _file = file;
    _createdDate = createdDate;
    _updateDate = updateDate;
    _active = active;
    _deleted = deleted;
    _seoTitle = seoTitle;
    _seoDescription = seoDescription;
    _seoKeywords = seoKeywords;
    _additionalCost = additionalCost;
    _slugHistory = slugHistory;
    _id = id;
    _slug = slug;
    _v = v;
}

  SubCategory.fromJson(dynamic json) {
    _name = json['name'];
    _description = json['description'];
    _descriptionAfterContent = json['description_after_content'];
    _parent = json['parent'];
    _file = json['file'];
    _createdDate = json['created_date'];
    _updateDate = json['update_date'];
    _active = json['active'];
    _deleted = json['deleted'];
    _seoTitle = json['seo_title'];
    _seoDescription = json['seo_description'];
    _seoKeywords = json['seo_keywords'];
    _additionalCost = json['additional_cost'];
    _slugHistory = json['slug_history'] != null ? json['slug_history'].cast<String>() : [];
    _id = json['_id'];
    _slug = json['slug'];
    _v = json['__v'];
  }
  String? _name;
  String? _description;
  String? _descriptionAfterContent;
  String? _parent;
  String? _file;
  String? _createdDate;
  String? _updateDate;
  num? _active;
  num? _deleted;
  String? _seoTitle;
  String? _seoDescription;
  String? _seoKeywords;
  String? _additionalCost;
  List<String>? _slugHistory;
  String? _id;
  String? _slug;
  num? _v;
SubCategory copyWith({  String? name,
  String? description,
  String? descriptionAfterContent,
  String? parent,
  String? file,
  String? createdDate,
  String? updateDate,
  num? active,
  num? deleted,
  String? seoTitle,
  String? seoDescription,
  String? seoKeywords,
  String? additionalCost,
  List<String>? slugHistory,
  String? id,
  String? slug,
  num? v,
}) => SubCategory(  name: name ?? _name,
  description: description ?? _description,
  descriptionAfterContent: descriptionAfterContent ?? _descriptionAfterContent,
  parent: parent ?? _parent,
  file: file ?? _file,
  createdDate: createdDate ?? _createdDate,
  updateDate: updateDate ?? _updateDate,
  active: active ?? _active,
  deleted: deleted ?? _deleted,
  seoTitle: seoTitle ?? _seoTitle,
  seoDescription: seoDescription ?? _seoDescription,
  seoKeywords: seoKeywords ?? _seoKeywords,
  additionalCost: additionalCost ?? _additionalCost,
  slugHistory: slugHistory ?? _slugHistory,
  id: id ?? _id,
  slug: slug ?? _slug,
  v: v ?? _v,
);
  String? get name => _name;
  String? get description => _description;
  String? get descriptionAfterContent => _descriptionAfterContent;
  String? get parent => _parent;
  String? get file => _file;
  String? get createdDate => _createdDate;
  String? get updateDate => _updateDate;
  num? get active => _active;
  num? get deleted => _deleted;
  String? get seoTitle => _seoTitle;
  String? get seoDescription => _seoDescription;
  String? get seoKeywords => _seoKeywords;
  String? get additionalCost => _additionalCost;
  List<String>? get slugHistory => _slugHistory;
  String? get id => _id;
  String? get slug => _slug;
  num? get v => _v;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['name'] = _name;
    map['description'] = _description;
    map['description_after_content'] = _descriptionAfterContent;
    map['parent'] = _parent;
    map['file'] = _file;
    map['created_date'] = _createdDate;
    map['update_date'] = _updateDate;
    map['active'] = _active;
    map['deleted'] = _deleted;
    map['seo_title'] = _seoTitle;
    map['seo_description'] = _seoDescription;
    map['seo_keywords'] = _seoKeywords;
    map['additional_cost'] = _additionalCost;
    map['slug_history'] = _slugHistory;
    map['_id'] = _id;
    map['slug'] = _slug;
    map['__v'] = _v;
    return map;
  }

}

Category categoryFromJson(String str) => Category.fromJson(json.decode(str));
String categoryToJson(Category data) => json.encode(data.toJson());
class Category {
  Category({
      String? name, 
      String? description, 
      String? descriptionAfterContent, 
      dynamic parent, 
      String? file, 
      String? createdDate, 
      String? updateDate, 
      num? active, 
      num? deleted, 
      String? seoTitle, 
      String? seoDescription, 
      String? seoKeywords, 
      String? additionalCost, 
      List<String>? slugHistory, 
      String? id, 
      String? slug, 
      num? v,}){
    _name = name;
    _description = description;
    _descriptionAfterContent = descriptionAfterContent;
    _parent = parent;
    _file = file;
    _createdDate = createdDate;
    _updateDate = updateDate;
    _active = active;
    _deleted = deleted;
    _seoTitle = seoTitle;
    _seoDescription = seoDescription;
    _seoKeywords = seoKeywords;
    _additionalCost = additionalCost;
    _slugHistory = slugHistory;
    _id = id;
    _slug = slug;
    _v = v;
}

  Category.fromJson(dynamic json) {
    _name = json['name'];
    _description = json['description'];
    _descriptionAfterContent = json['description_after_content'];
    _parent = json['parent'];
    _file = json['file'];
    _createdDate = json['created_date'];
    _updateDate = json['update_date'];
    _active = json['active'];
    _deleted = json['deleted'];
    _seoTitle = json['seo_title'];
    _seoDescription = json['seo_description'];
    _seoKeywords = json['seo_keywords'];
    _additionalCost = json['additional_cost'];
    _slugHistory = json['slug_history'] != null ? json['slug_history'].cast<String>() : [];
    _id = json['_id'];
    _slug = json['slug'];
    _v = json['__v'];
  }
  String? _name;
  String? _description;
  String? _descriptionAfterContent;
  dynamic _parent;
  String? _file;
  String? _createdDate;
  String? _updateDate;
  num? _active;
  num? _deleted;
  String? _seoTitle;
  String? _seoDescription;
  String? _seoKeywords;
  String? _additionalCost;
  List<String>? _slugHistory;
  String? _id;
  String? _slug;
  num? _v;
Category copyWith({  String? name,
  String? description,
  String? descriptionAfterContent,
  dynamic parent,
  String? file,
  String? createdDate,
  String? updateDate,
  num? active,
  num? deleted,
  String? seoTitle,
  String? seoDescription,
  String? seoKeywords,
  String? additionalCost,
  List<String>? slugHistory,
  String? id,
  String? slug,
  num? v,
}) => Category(  name: name ?? _name,
  description: description ?? _description,
  descriptionAfterContent: descriptionAfterContent ?? _descriptionAfterContent,
  parent: parent ?? _parent,
  file: file ?? _file,
  createdDate: createdDate ?? _createdDate,
  updateDate: updateDate ?? _updateDate,
  active: active ?? _active,
  deleted: deleted ?? _deleted,
  seoTitle: seoTitle ?? _seoTitle,
  seoDescription: seoDescription ?? _seoDescription,
  seoKeywords: seoKeywords ?? _seoKeywords,
  additionalCost: additionalCost ?? _additionalCost,
  slugHistory: slugHistory ?? _slugHistory,
  id: id ?? _id,
  slug: slug ?? _slug,
  v: v ?? _v,
);
  String? get name => _name;
  String? get description => _description;
  String? get descriptionAfterContent => _descriptionAfterContent;
  dynamic get parent => _parent;
  String? get file => _file;
  String? get createdDate => _createdDate;
  String? get updateDate => _updateDate;
  num? get active => _active;
  num? get deleted => _deleted;
  String? get seoTitle => _seoTitle;
  String? get seoDescription => _seoDescription;
  String? get seoKeywords => _seoKeywords;
  String? get additionalCost => _additionalCost;
  List<String>? get slugHistory => _slugHistory;
  String? get id => _id;
  String? get slug => _slug;
  num? get v => _v;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['name'] = _name;
    map['description'] = _description;
    map['description_after_content'] = _descriptionAfterContent;
    map['parent'] = _parent;
    map['file'] = _file;
    map['created_date'] = _createdDate;
    map['update_date'] = _updateDate;
    map['active'] = _active;
    map['deleted'] = _deleted;
    map['seo_title'] = _seoTitle;
    map['seo_description'] = _seoDescription;
    map['seo_keywords'] = _seoKeywords;
    map['additional_cost'] = _additionalCost;
    map['slug_history'] = _slugHistory;
    map['_id'] = _id;
    map['slug'] = _slug;
    map['__v'] = _v;
    return map;
  }

}
/*

DestinationLocation destinationLocationFromJson(String str) => DestinationLocation.fromJson(json.decode(str));
String destinationLocationToJson(DestinationLocation data) => json.encode(data.toJson());
class DestinationLocation {
  DestinationLocation({
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
      dynamic landmark, 
      String? id, 
      String? city, 
      String? state, 
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

  DestinationLocation.fromJson(dynamic json) {
    _position = json['position'] != null ? Position.fromJson(json['position']) : null;
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
    _city = json['city'];
    _state = json['state'];
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
  dynamic _landmark;
  String? _id;
  String? _city;
  String? _state;
  String? _createdDate;
  num? _v;
DestinationLocation copyWith({  Position? position,
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
  dynamic landmark,
  String? id,
  String? city,
  String? state,
  String? createdDate,
  num? v,
}) => DestinationLocation(  position: position ?? _position,
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
  dynamic get landmark => _landmark;
  String? get id => _id;
  String? get city => _city;
  String? get state => _state;
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
    map['city'] = _city;
    map['state'] = _state;
    map['created_date'] = _createdDate;
    map['__v'] = _v;
    return map;
  }

}

SourceLocation sourceLocationFromJson(String str) => SourceLocation.fromJson(json.decode(str));
String sourceLocationToJson(SourceLocation data) => json.encode(data.toJson());
class SourceLocation {
  SourceLocation({
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
      dynamic landmark, 
      String? id, 
      String? city, 
      String? state, 
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

  SourceLocation.fromJson(dynamic json) {
    _position = json['position'] != null ? Position.fromJson(json['position']) : null;
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
    _city = json['city'];
    _state = json['state'];
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
  dynamic _landmark;
  String? _id;
  String? _city;
  String? _state;
  String? _createdDate;
  num? _v;
SourceLocation copyWith({  Position? position,
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
  dynamic landmark,
  String? id,
  String? city,
  String? state,
  String? createdDate,
  num? v,
}) => SourceLocation(  position: position ?? _position,
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
  dynamic get landmark => _landmark;
  String? get id => _id;
  String? get city => _city;
  String? get state => _state;
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
    map['city'] = _city;
    map['state'] = _state;
    map['created_date'] = _createdDate;
    map['__v'] = _v;
    return map;
  }

}*/
