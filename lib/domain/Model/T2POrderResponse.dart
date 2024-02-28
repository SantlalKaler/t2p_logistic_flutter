import 'dart:convert';

import 'package:t2p_logistic/domain/Model/user/AddressListResponse.dart';
import 'package:t2p_logistic/domain/Model/user/VerifyOtpResponse.dart';
T2pOrderResponse t2pOrderResponseFromJson(String str) => T2pOrderResponse.fromJson(json.decode(str));
String t2pOrderResponseToJson(T2pOrderResponse data) => json.encode(data.toJson());
class T2pOrderResponse {
  T2pOrderResponse({
      String? status, 
      List<T2POrder>? order,
      String? message,}){
    _status = status;
    _order = order;
    _message = message;
}

  T2pOrderResponse.fromJson(dynamic json) {
    _status = json['status'];
    if (json['result'] != null) {
      _order = [];
      json['result'].forEach((v) {
        _order?.add(T2POrder.fromJson(v));
      });
    }
    _message = json['message'];
  }
  String? _status;
  List<T2POrder>? _order;
  String? _message;
T2pOrderResponse copyWith({  String? status,
  List<T2POrder>? order,
  String? message,
}) => T2pOrderResponse(  status: status ?? _status,
  order: order ?? _order,
  message: message ?? _message,
);
  String? get status => _status;
  List<T2POrder>? get order => _order;
  String? get message => _message;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['status'] = _status;
    if (_order != null) {
      map['result'] = _order?.map((v) => v.toJson()).toList();
    }
    map['message'] = _message;
    return map;
  }

}

T2POrder t2POrderFromJson(String str) => T2POrder.fromJson(json.decode(str));
String t2POrderToJson(T2POrder data) => json.encode(data.toJson());
class T2POrder {
  T2POrder({
      Position? position, 
      VendorPosition? vendorPosition, 
      CargoPosition? cargoPosition, 
      DeliveryPartnerPosition? deliveryPartnerPosition, 
      String? orderid, 
      String? transactionid, 
      String? gateway, 
      User? user, 
      Vendor? vendor, 
      User? pickupPartner,
      num? pickupPartnerCommission, 
      User? pickupBoy,
      CargoPartner? cargoPartner, 
      String? cargoPartnerCommission,
      DeliveryPartner? deliveryPartner, 
      User? lpHead,
      User? lpManager,
      String? deliveryPartnerCommission,
      String? totalWeight,
      User? deliveryBoy,
      String? orderCity, 
      String? vendorCity, 
      String? coupon, 
      String? coupontype, 
      String? couponamount, 
      String? price, 
      String? finalprice, 
      String? codCollected, 
      String? express, 
      String? totalShippingPrice, 
      String? totalPackingPrice, 
      String? totalCGST, 
      String? totalSGST, 
      String? totalIGST, 
      String? additionalCost, 
      String? status, 
      String? customerOrderStatus, 
      String? timeslot, 
      String? updateDate, 
      dynamic otp, 
      String? deliveryDate, 
      String? deleted,
      String? scheduleTime, 
      String? scheduleDate, 
      String? scheduleStatus, 
      String? scheduleStatusTo, 
      String? distance,
    String? paid,
    String? bundleQr,
      String? bundleId, 
      String? bag, 
      dynamic boxId, 
      String? hasNote, 
      String? walletDiscount, 
      String? pickupWeight, 
      String? deliveryWeight, 
      String? partialTransaction, 
      String? partialTransactionAmount, 
      String? returnReason, 
      num? complementary, 
      String? browser, 
      num? pickupDistance, 
      num? deliveryDistance, 
      String? tipPrice, 
      num? orderCount, 
      String? lastMileLongDistanceExtraCharge, 
      String? lastMileLongDistance, 
      String? lastMileFreeLongDistance, 
      String? lastMileLongDistanceMultiplier, 
      String? id, 
      Address? address, 
      List<Products>? products, 
      String? createdDate, 
      num? v,}){
    _position = position;
    _vendorPosition = vendorPosition;
    _cargoPosition = cargoPosition;
    _deliveryPartnerPosition = deliveryPartnerPosition;
    _orderid = orderid;
    _transactionid = transactionid;
    _gateway = gateway;
    _user = user;
    _vendor = vendor;
    _pickupPartner = pickupPartner;
    _pickupPartnerCommission = pickupPartnerCommission;
    _pickupBoy = pickupBoy;
    _cargoPartner = cargoPartner;
    _cargoPartnerCommission = cargoPartnerCommission;
    _deliveryPartner = deliveryPartner;
    _lpHead = lpHead;
    _lpManager = lpManager;
    _deliveryPartnerCommission = deliveryPartnerCommission;
    _totalWeight = totalWeight;
    _deliveryBoy = deliveryBoy;
    _orderCity = orderCity;
    _vendorCity = vendorCity;
    _coupon = coupon;
    _coupontype = coupontype;
    _couponamount = couponamount;
    _price = price;
    _finalprice = finalprice;
    _codCollected = codCollected;
    _express = express;
    _totalShippingPrice = totalShippingPrice;
    _totalPackingPrice = totalPackingPrice;
    _totalCGST = totalCGST;
    _totalSGST = totalSGST;
    _totalIGST = totalIGST;
    _additionalCost = additionalCost;
    _status = status;
    _customerOrderStatus = customerOrderStatus;
    _timeslot = timeslot;
    _updateDate = updateDate;
    _otp = otp;
    _deliveryDate = deliveryDate;
    _deleted = deleted;
    _scheduleTime = scheduleTime;
    _scheduleDate = scheduleDate;
    _scheduleStatus = scheduleStatus;
    _scheduleStatusTo = scheduleStatusTo;
    _distance = distance;
    _paid = paid;
    _bundleQr = bundleQr;
    _bundleId = bundleId;
    _bag = bag;
    _boxId = boxId;
    _hasNote = hasNote;
    _walletDiscount = walletDiscount;
    _pickupWeight = pickupWeight;
    _deliveryWeight = deliveryWeight;
    _partialTransaction = partialTransaction;
    _partialTransactionAmount = partialTransactionAmount;
    _returnReason = returnReason;
    _complementary = complementary;
    _browser = browser;
    _pickupDistance = pickupDistance;
    _deliveryDistance = deliveryDistance;
    _tipPrice = tipPrice;
    _orderCount = orderCount;
    _lastMileLongDistanceExtraCharge = lastMileLongDistanceExtraCharge;
    _lastMileLongDistance = lastMileLongDistance;
    _lastMileFreeLongDistance = lastMileFreeLongDistance;
    _lastMileLongDistanceMultiplier = lastMileLongDistanceMultiplier;
    _id = id;
    _address = address;
    _products = products;
    _createdDate = createdDate;
    _v = v;
}

  T2POrder.fromJson(dynamic json) {
    _position = json['position'] != null ? Position.fromJson(json['position']) : null;
    _vendorPosition = json['vendor_position'] != null ? VendorPosition.fromJson(json['vendor_position']) : null;
    _cargoPosition = json['cargo_position'] != null ? CargoPosition.fromJson(json['cargo_position']) : null;
    _deliveryPartnerPosition = json['delivery_partner_position'] != null ? DeliveryPartnerPosition.fromJson(json['delivery_partner_position']) : null;
    _orderid = json['orderid'];
    _transactionid = json['transactionid'];
    _gateway = json['gateway'];
    _user = json['user'] != null ? User.fromJson(json['user']) : null;
    _vendor = json['vendor'] != null ? Vendor.fromJson(json['vendor']) : null;
    _pickupPartner = json['pickup_partner'] != null ? User.fromJson(json['pickup_partner']) : null;
    _pickupPartnerCommission = json['pickup_partner_commission'];
    _pickupBoy = json['pickup_boy'] != null ? User.fromJson(json['pickup_boy']) : null;
    _cargoPartner = json['cargo_partner'] != null ? CargoPartner.fromJson(json['cargo_partner']) : null;
    _cargoPartnerCommission = json['cargo_partner_commission'].toString();
    _deliveryPartner = json['delivery_partner'] != null ? DeliveryPartner.fromJson(json['delivery_partner']) : null;
    _lpHead = json['lp_head'] != null ? User.fromJson(json['lp_head']) : null;
    _lpManager = json['lp_manager'] != null ? User.fromJson(json['lp_manager']) : null;
    _deliveryPartnerCommission = json['delivery_partner_commission'].toString();
    _totalWeight = json['total_weight'];
    _deliveryBoy = json['delivery_boy'] != null ? User.fromJson(json['delivery_boy']) : null;
    _orderCity = json['order_city'];
    _vendorCity = json['vendor_city'];
    _coupon = json['coupon'];
    _coupontype = json['coupontype'];
    _couponamount = json['couponamount'];
    _price = json['price'];
    _finalprice = json['finalprice'];
    _codCollected = json['cod_collected'];
    _express = json['express'];
    _totalShippingPrice = json['totalShippingPrice'];
    _totalPackingPrice = json['totalPackingPrice'];
    _totalCGST = json['totalCGST'];
    _totalSGST = json['totalSGST'];
    _totalIGST = json['totalIGST'];
    _additionalCost = json['additional_cost'];
    _status = json['status'];
    _customerOrderStatus = json['customer_order_status'];
    _timeslot = json['timeslot'];
    _updateDate = json['update_date'];
    _otp = json['otp'];
    _deliveryDate = json['delivery_date'];
    _deleted = json['deleted'].toString();
    _scheduleTime = json['schedule_time'];
    _scheduleDate = json['schedule_date'];
    _scheduleStatus = json['schedule_status'];
    _scheduleStatusTo = json['schedule_status_to'];
    _distance = json['distance'].toString();
    _paid = json['paid'].toString();
    _bundleQr = json['bundle_qr'].toString();
    _bundleId = json['bundle_id'];
    _bag = json['bag'];
    _boxId = json['box_id'];
    _hasNote = json['has_note'];
    _walletDiscount = json['wallet_discount'];
    _pickupWeight = json['pickup_weight'];
    _deliveryWeight = json['delivery_weight'];
    _partialTransaction = json['partial_transaction'];
    _partialTransactionAmount = json['partial_transaction_amount'];
    _returnReason = json['return_reason'];
    _complementary = json['complementary'];
    _browser = json['browser'];
    _pickupDistance = json['pickup_distance'];
    _deliveryDistance = json['delivery_distance'];
    _tipPrice = json['tip_price'];
    _orderCount = json['order_count'];
    _lastMileLongDistanceExtraCharge = json['last_mile_long_distance_extra_charge'];
    _lastMileLongDistance = json['last_mile_long_distance'];
    _lastMileFreeLongDistance = json['last_mile_free_long_distance'];
    _lastMileLongDistanceMultiplier = json['last_mile_long_distance_multiplier'];
    _id = json['_id'];
    _address = json['address'] != null ? Address.fromJson(json['address']) : null;
    if (json['products'] != null) {
      _products = [];
      json['products'].forEach((v) {
        _products?.add(Products.fromJson(v));
      });
    }
    _createdDate = json['created_date'];
    _v = json['__v'];
  }
  Position? _position;
  VendorPosition? _vendorPosition;
  CargoPosition? _cargoPosition;
  DeliveryPartnerPosition? _deliveryPartnerPosition;
  String? _orderid;
  String? _transactionid;
  String? _gateway;
  User? _user;
  Vendor? _vendor;
  User? _pickupPartner;
  num? _pickupPartnerCommission;
  User? _pickupBoy;
  CargoPartner? _cargoPartner;
  String? _cargoPartnerCommission;
  DeliveryPartner? _deliveryPartner;
  User? _lpHead;
  User? _lpManager;
  String? _deliveryPartnerCommission;
  String? _totalWeight;
  User? _deliveryBoy;
  String? _orderCity;
  String? _vendorCity;
  String? _coupon;
  String? _coupontype;
  String? _couponamount;
  String? _price;
  String? _finalprice;
  String? _codCollected;
  String? _express;
  String? _totalShippingPrice;
  String? _totalPackingPrice;
  String? _totalCGST;
  String? _totalSGST;
  String? _totalIGST;
  String? _additionalCost;
  String? _status;
  String? _customerOrderStatus;
  String? _timeslot;
  String? _updateDate;
  dynamic _otp;
  String? _deliveryDate;
  String? _deleted;
  String? _scheduleTime;
  String? _scheduleDate;
  String? _scheduleStatus;
  String? _scheduleStatusTo;
  String? _distance;
  String? _paid;
  String? _bundleQr;
  String? _bundleId;
  String? _bag;
  dynamic _boxId;
  String? _hasNote;
  String? _walletDiscount;
  String? _pickupWeight;
  String? _deliveryWeight;
  String? _partialTransaction;
  String? _partialTransactionAmount;
  String? _returnReason;
  num? _complementary;
  String? _browser;
  num? _pickupDistance;
  num? _deliveryDistance;
  String? _tipPrice;
  num? _orderCount;
  String? _lastMileLongDistanceExtraCharge;
  String? _lastMileLongDistance;
  String? _lastMileFreeLongDistance;
  String? _lastMileLongDistanceMultiplier;
  String? _id;
  Address? _address;
  List<Products>? _products;
  String? _createdDate;
  num? _v;
T2POrder copyWith({  Position? position,
  VendorPosition? vendorPosition,
  CargoPosition? cargoPosition,
  DeliveryPartnerPosition? deliveryPartnerPosition,
  String? orderid,
  String? transactionid,
  String? gateway,
  User? user,
  Vendor? vendor,
  User? pickupPartner,
  num? pickupPartnerCommission,
  User? pickupBoy,
  CargoPartner? cargoPartner,
  String? cargoPartnerCommission,
  DeliveryPartner? UsereryPartner,
  User? lpHead,
  User? lpManager,
  String? deliveryPartnerCommission,
  String? totalWeight,
  User? deliveryBoy,
  String? orderCity,
  String? vendorCity,
  String? coupon,
  String? coupontype,
  String? couponamount,
  String? price,
  String? finalprice,
  String? codCollected,
  String? express,
  String? totalShippingPrice,
  String? totalPackingPrice,
  String? totalCGST,
  String? totalSGST,
  String? totalIGST,
  String? additionalCost,
  String? status,
  String? customerOrderStatus,
  String? timeslot,
  String? updateDate,
  dynamic otp,
  String? deliveryDate,
  String? deleted,
  String? scheduleTime,
  String? scheduleDate,
  String? scheduleStatus,
  String? scheduleStatusTo,
  String? distance,
  String? paid,
  String? bundleQr,
  String? bundleId,
  String? bag,
  dynamic boxId,
  String? hasNote,
  String? walletDiscount,
  String? pickupWeight,
  String? deliveryWeight,
  String? partialTransaction,
  String? partialTransactionAmount,
  String? returnReason,
  num? complementary,
  String? browser,
  num? pickupDistance,
  num? deliveryDistance,
  String? tipPrice,
  num? orderCount,
  String? lastMileLongDistanceExtraCharge,
  String? lastMileLongDistance,
  String? lastMileFreeLongDistance,
  String? lastMileLongDistanceMultiplier,
  String? id,
  Address? address,
  List<Products>? products,
  String? createdDate,
  num? v,
}) => T2POrder(  position: position ?? _position,
  vendorPosition: vendorPosition ?? _vendorPosition,
  cargoPosition: cargoPosition ?? _cargoPosition,
  deliveryPartnerPosition: deliveryPartnerPosition ?? _deliveryPartnerPosition,
  orderid: orderid ?? _orderid,
  transactionid: transactionid ?? _transactionid,
  gateway: gateway ?? _gateway,
  user: user ?? _user,
  vendor: vendor ?? _vendor,
  pickupPartner: pickupPartner ?? _pickupPartner,
  pickupPartnerCommission: pickupPartnerCommission ?? _pickupPartnerCommission,
  pickupBoy: pickupBoy ?? _pickupBoy,
  cargoPartner: cargoPartner ?? _cargoPartner,
  cargoPartnerCommission: cargoPartnerCommission ?? _cargoPartnerCommission,
  deliveryPartner: deliveryPartner ?? _deliveryPartner,
  lpHead: lpHead ?? _lpHead,
  lpManager: lpManager ?? _lpManager,
  deliveryPartnerCommission: deliveryPartnerCommission ?? _deliveryPartnerCommission,
  totalWeight: totalWeight ?? _totalWeight,
  deliveryBoy: deliveryBoy ?? _deliveryBoy,
  orderCity: orderCity ?? _orderCity,
  vendorCity: vendorCity ?? _vendorCity,
  coupon: coupon ?? _coupon,
  coupontype: coupontype ?? _coupontype,
  couponamount: couponamount ?? _couponamount,
  price: price ?? _price,
  finalprice: finalprice ?? _finalprice,
  codCollected: codCollected ?? _codCollected,
  express: express ?? _express,
  totalShippingPrice: totalShippingPrice ?? _totalShippingPrice,
  totalPackingPrice: totalPackingPrice ?? _totalPackingPrice,
  totalCGST: totalCGST ?? _totalCGST,
  totalSGST: totalSGST ?? _totalSGST,
  totalIGST: totalIGST ?? _totalIGST,
  additionalCost: additionalCost ?? _additionalCost,
  status: status ?? _status,
  customerOrderStatus: customerOrderStatus ?? _customerOrderStatus,
  timeslot: timeslot ?? _timeslot,
  updateDate: updateDate ?? _updateDate,
  otp: otp ?? _otp,
  deliveryDate: deliveryDate ?? _deliveryDate,
  deleted: deleted ?? _deleted,
  scheduleTime: scheduleTime ?? _scheduleTime,
  scheduleDate: scheduleDate ?? _scheduleDate,
  scheduleStatus: scheduleStatus ?? _scheduleStatus,
  scheduleStatusTo: scheduleStatusTo ?? _scheduleStatusTo,
  distance: distance ?? _distance,
  paid: paid ?? _paid,
  bundleQr: bundleQr ?? _bundleQr,
  bundleId: bundleId ?? _bundleId,
  bag: bag ?? _bag,
  boxId: boxId ?? _boxId,
  hasNote: hasNote ?? _hasNote,
  walletDiscount: walletDiscount ?? _walletDiscount,
  pickupWeight: pickupWeight ?? _pickupWeight,
  deliveryWeight: deliveryWeight ?? _deliveryWeight,
  partialTransaction: partialTransaction ?? _partialTransaction,
  partialTransactionAmount: partialTransactionAmount ?? _partialTransactionAmount,
  returnReason: returnReason ?? _returnReason,
  complementary: complementary ?? _complementary,
  browser: browser ?? _browser,
  pickupDistance: pickupDistance ?? _pickupDistance,
  deliveryDistance: deliveryDistance ?? _deliveryDistance,
  tipPrice: tipPrice ?? _tipPrice,
  orderCount: orderCount ?? _orderCount,
  lastMileLongDistanceExtraCharge: lastMileLongDistanceExtraCharge ?? _lastMileLongDistanceExtraCharge,
  lastMileLongDistance: lastMileLongDistance ?? _lastMileLongDistance,
  lastMileFreeLongDistance: lastMileFreeLongDistance ?? _lastMileFreeLongDistance,
  lastMileLongDistanceMultiplier: lastMileLongDistanceMultiplier ?? _lastMileLongDistanceMultiplier,
  id: id ?? _id,
  address: address ?? _address,
  products: products ?? _products,
  createdDate: createdDate ?? _createdDate,
  v: v ?? _v,
);
  Position? get position => _position;
  VendorPosition? get vendorPosition => _vendorPosition;
  CargoPosition? get cargoPosition => _cargoPosition;
  DeliveryPartnerPosition? get deliveryPartnerPosition => _deliveryPartnerPosition;
  String? get orderid => _orderid;
  String? get transactionid => _transactionid;
  String? get gateway => _gateway;
  User? get user => _user;
  Vendor? get vendor => _vendor;
  User? get pickupPartner => _pickupPartner;
  num? get pickupPartnerCommission => _pickupPartnerCommission;
  User? get pickupBoy => _pickupBoy;
  CargoPartner? get cargoPartner => _cargoPartner;
  String? get cargoPartnerCommission => _cargoPartnerCommission;
  DeliveryPartner? get deliveryPartner => _deliveryPartner;
  User? get lpHead => _lpHead;
  User? get lpManager => _lpManager;
  String? get deliveryPartnerCommission => _deliveryPartnerCommission;
  String? get totalWeight => _totalWeight;
  User? get deliveryBoy => _deliveryBoy;
  String? get orderCity => _orderCity;
  String? get vendorCity => _vendorCity;
  String? get coupon => _coupon;
  String? get coupontype => _coupontype;
  String? get couponamount => _couponamount;
  String? get price => _price;
  String? get finalprice => _finalprice;
  String? get codCollected => _codCollected;
  String? get express => _express;
  String? get totalShippingPrice => _totalShippingPrice;
  String? get totalPackingPrice => _totalPackingPrice;
  String? get totalCGST => _totalCGST;
  String? get totalSGST => _totalSGST;
  String? get totalIGST => _totalIGST;
  String? get additionalCost => _additionalCost;
  String? get status => _status;
  String? get customerOrderStatus => _customerOrderStatus;
  String? get timeslot => _timeslot;
  String? get updateDate => _updateDate;
  dynamic get otp => _otp;
  String? get deliveryDate => _deliveryDate;
  String? get deleted => _deleted;
  String? get scheduleTime => _scheduleTime;
  String? get scheduleDate => _scheduleDate;
  String? get scheduleStatus => _scheduleStatus;
  String? get scheduleStatusTo => _scheduleStatusTo;
  String? get distance => _distance;
  String? get paid => _paid;
  String? get bundleQr => _bundleQr;
  String? get bundleId => _bundleId;
  String? get bag => _bag;
  dynamic get boxId => _boxId;
  String? get hasNote => _hasNote;
  String? get walletDiscount => _walletDiscount;
  String? get pickupWeight => _pickupWeight;
  String? get deliveryWeight => _deliveryWeight;
  String? get partialTransaction => _partialTransaction;
  String? get partialTransactionAmount => _partialTransactionAmount;
  String? get returnReason => _returnReason;
  num? get complementary => _complementary;
  String? get browser => _browser;
  num? get pickupDistance => _pickupDistance;
  num? get deliveryDistance => _deliveryDistance;
  String? get tipPrice => _tipPrice;
  num? get orderCount => _orderCount;
  String? get lastMileLongDistanceExtraCharge => _lastMileLongDistanceExtraCharge;
  String? get lastMileLongDistance => _lastMileLongDistance;
  String? get lastMileFreeLongDistance => _lastMileFreeLongDistance;
  String? get lastMileLongDistanceMultiplier => _lastMileLongDistanceMultiplier;
  String? get id => _id;
  Address? get address => _address;
  List<Products>? get products => _products;
  String? get createdDate => _createdDate;
  num? get v => _v;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (_position != null) {
      map['position'] = _position?.toJson();
    }
    if (_vendorPosition != null) {
      map['vendor_position'] = _vendorPosition?.toJson();
    }
    if (_cargoPosition != null) {
      map['cargo_position'] = _cargoPosition?.toJson();
    }
    if (_deliveryPartnerPosition != null) {
      map['delivery_partner_position'] = _deliveryPartnerPosition?.toJson();
    }
    map['orderid'] = _orderid;
    map['transactionid'] = _transactionid;
    map['gateway'] = _gateway;
    if (_user != null) {
      map['user'] = _user?.toJson();
    }
    if (_vendor != null) {
      map['vendor'] = _vendor?.toJson();
    }
    if (_pickupPartner != null) {
      map['pickup_partner'] = _pickupPartner?.toJson();
    }
    map['pickup_partner_commission'] = _pickupPartnerCommission;
    if (_pickupBoy != null) {
      map['pickup_boy'] = _pickupBoy?.toJson();
    }
    if (_cargoPartner != null) {
      map['cargo_partner'] = _cargoPartner?.toJson();
    }
    map['cargo_partner_commission'] = _cargoPartnerCommission;
    if (_deliveryPartner != null) {
      map['delivery_partner'] = _deliveryPartner?.toJson();
    }
    if (_lpHead != null) {
      map['lp_head'] = _lpHead?.toJson();
    }
    if (_lpManager != null) {
      map['lp_manager'] = _lpManager?.toJson();
    }
    map['delivery_partner_commission'] = _deliveryPartnerCommission;
    map['total_weight'] = _totalWeight;
    if (_deliveryBoy != null) {
      map['delivery_boy'] = _deliveryBoy?.toJson();
    }
    map['order_city'] = _orderCity;
    map['vendor_city'] = _vendorCity;
    map['coupon'] = _coupon;
    map['coupontype'] = _coupontype;
    map['couponamount'] = _couponamount;
    map['price'] = _price;
    map['finalprice'] = _finalprice;
    map['cod_collected'] = _codCollected;
    map['express'] = _express;
    map['totalShippingPrice'] = _totalShippingPrice;
    map['totalPackingPrice'] = _totalPackingPrice;
    map['totalCGST'] = _totalCGST;
    map['totalSGST'] = _totalSGST;
    map['totalIGST'] = _totalIGST;
    map['additional_cost'] = _additionalCost;
    map['status'] = _status;
    map['customer_order_status'] = _customerOrderStatus;
    map['timeslot'] = _timeslot;
    map['update_date'] = _updateDate;
    map['otp'] = _otp;
    map['delivery_date'] = _deliveryDate;
    map['deleted'] = _deleted;
    map['schedule_time'] = _scheduleTime;
    map['schedule_date'] = _scheduleDate;
    map['schedule_status'] = _scheduleStatus;
    map['schedule_status_to'] = _scheduleStatusTo;
    map['distance'] = _distance;
    map['paid'] = _paid;
    map['bundle_qr'] = _bundleQr;
    map['bundle_id'] = _bundleId;
    map['bag'] = _bag;
    map['box_id'] = _boxId;
    map['has_note'] = _hasNote;
    map['wallet_discount'] = _walletDiscount;
    map['pickup_weight'] = _pickupWeight;
    map['delivery_weight'] = _deliveryWeight;
    map['partial_transaction'] = _partialTransaction;
    map['partial_transaction_amount'] = _partialTransactionAmount;
    map['return_reason'] = _returnReason;
    map['complementary'] = _complementary;
    map['browser'] = _browser;
    map['pickup_distance'] = _pickupDistance;
    map['delivery_distance'] = _deliveryDistance;
    map['tip_price'] = _tipPrice;
    map['order_count'] = _orderCount;
    map['last_mile_long_distance_extra_charge'] = _lastMileLongDistanceExtraCharge;
    map['last_mile_long_distance'] = _lastMileLongDistance;
    map['last_mile_free_long_distance'] = _lastMileFreeLongDistance;
    map['last_mile_long_distance_multiplier'] = _lastMileLongDistanceMultiplier;
    map['_id'] = _id;
    if (_address != null) {
      map['address'] = _address?.toJson();
    }
    if (_products != null) {
      map['products'] = _products?.map((v) => v.toJson()).toList();
    }
    map['created_date'] = _createdDate;
    map['__v'] = _v;
    return map;
  }

}

Products productsFromJson(String str) => Products.fromJson(json.decode(str));
String productsToJson(Products data) => json.encode(data.toJson());
class Products {
  Products({
      String? user, 
      Product? product, 
      String? category, 
      String? subCategory, 
      String? cuisine, 
      String? brand, 
      String? vendor, 
      String? city, 
      num? quantity,
      num? price,
      String? productname, 
      String? id,}){
    _user = user;
    _product = product;
    _category = category;
    _subCategory = subCategory;
    _cuisine = cuisine;
    _brand = brand;
    _vendor = vendor;
    _city = city;
    _quantity = quantity;
    _price = price;
    _productname = productname;
    _id = id;
}

  Products.fromJson(dynamic json) {
    _user = json['user'];
    _product = json['product'] != null ? Product.fromJson(json['product']) : null;
    _category = json['category'];
    _subCategory = json['sub_category'];
    _cuisine = json['cuisine'];
    _brand = json['brand'];
    _vendor = json['vendor'];
    _city = json['city'];
    _quantity = json['quantity'];
    _price = json['price'];
    _productname = json['productname'];
    _id = json['_id'];
  }
  String? _user;
  Product? _product;
  String? _category;
  String? _subCategory;
  String? _cuisine;
  String? _brand;
  String? _vendor;
  String? _city;
  num? _quantity;
  num? _price;
  String? _productname;
  String? _id;
Products copyWith({  String? user,
  Product? product,
  String? category,
  String? subCategory,
  String? cuisine,
  String? brand,
  String? vendor,
  String? city,
  num? quantity,
  num? price,
  String? productname,
  String? id,
}) => Products(  user: user ?? _user,
  product: product ?? _product,
  category: category ?? _category,
  subCategory: subCategory ?? _subCategory,
  cuisine: cuisine ?? _cuisine,
  brand: brand ?? _brand,
  vendor: vendor ?? _vendor,
  city: city ?? _city,
  quantity: quantity ?? _quantity,
  price: price ?? _price,
  productname: productname ?? _productname,
  id: id ?? _id,
);
  String? get user => _user;
  Product? get product => _product;
  String? get category => _category;
  String? get subCategory => _subCategory;
  String? get cuisine => _cuisine;
  String? get brand => _brand;
  String? get vendor => _vendor;
  String? get city => _city;
  num? get quantity => _quantity;
  num? get price => _price;
  String? get productname => _productname;
  String? get id => _id;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['user'] = _user;
    if (_product != null) {
      map['product'] = _product?.toJson();
    }
    map['category'] = _category;
    map['sub_category'] = _subCategory;
    map['cuisine'] = _cuisine;
    map['brand'] = _brand;
    map['vendor'] = _vendor;
    map['city'] = _city;
    map['quantity'] = _quantity;
    map['price'] = _price;
    map['productname'] = _productname;
    map['_id'] = _id;
    return map;
  }

}

Product productFromJson(String str) => Product.fromJson(json.decode(str));
String productToJson(Product data) => json.encode(data.toJson());
class Product {
  Product({
      dynamic comboProducts, 
      String? name, 
      String? category, 
      String? subCategory, 
      String? cuisine, 
      String? brand, 
      String? vendor, 
      String? desc, 
      String? shortDesc, 
      List<File>? file, 
      num? price, 
      num? sellingPrice, 
      String? discountedPrice, 
      String? purchasePrice, 
      String? batchno, 
      String? city, 
      String? commission, 
      String? packagingCharge, 
      String? taxStatus, 
      String? cgst, 
      String? sgst, 
      String? igst, 
      String? sku, 
      String? stockQty, 
      String? backorders, 
      String? threshold, 
      num? manageStock, 
      String? weight, 
      String? length, 
      String? width, 
      String? height, 
      String? attribute, 
      String? tags, 
      String? startDate, 
      String? endDate, 
      String? createdDate, 
      String? updateDate, 
      num? active, 
      num? deal, 
      num? featured, 
      num? deleted, 
      bool? express, 
      String? addedBy, 
      num? point, 
      String? stockProduct, 
      num? consumable, 
      String? seoTitle, 
      String? seoDescription, 
      String? seoKeywords, 
      num? top, 
      num? taste, 
      String? rating, 
      List<String>? slugHistory, 
      String? id, 
      String? pointExpDate, 
      String? slug, 
      num? v,}){
    _comboProducts = comboProducts;
    _name = name;
    _category = category;
    _subCategory = subCategory;
    _cuisine = cuisine;
    _brand = brand;
    _vendor = vendor;
    _desc = desc;
    _shortDesc = shortDesc;
    _file = file;
    _price = price;
    _sellingPrice = sellingPrice;
    _discountedPrice = discountedPrice;
    _purchasePrice = purchasePrice;
    _batchno = batchno;
    _city = city;
    _commission = commission;
    _packagingCharge = packagingCharge;
    _taxStatus = taxStatus;
    _cgst = cgst;
    _sgst = sgst;
    _igst = igst;
    _sku = sku;
    _stockQty = stockQty;
    _backorders = backorders;
    _threshold = threshold;
    _manageStock = manageStock;
    _weight = weight;
    _length = length;
    _width = width;
    _height = height;
    _attribute = attribute;
    _tags = tags;
    _startDate = startDate;
    _endDate = endDate;
    _createdDate = createdDate;
    _updateDate = updateDate;
    _active = active;
    _deal = deal;
    _featured = featured;
    _deleted = deleted;
    _express = express;
    _addedBy = addedBy;
    _point = point;
    _stockProduct = stockProduct;
    _consumable = consumable;
    _seoTitle = seoTitle;
    _seoDescription = seoDescription;
    _seoKeywords = seoKeywords;
    _top = top;
    _taste = taste;
    _rating = rating;
    _slugHistory = slugHistory;
    _id = id;
    _pointExpDate = pointExpDate;
    _slug = slug;
    _v = v;
}

  Product.fromJson(dynamic json) {
    _comboProducts = json['combo_products'];
    _name = json['name'];
    _category = json['category'];
    _subCategory = json['sub_category'];
    _cuisine = json['cuisine'];
    _brand = json['brand'];
    _vendor = json['vendor'];
    _desc = json['desc'];
    _shortDesc = json['short_desc'];
    if (json['file'] != null) {
      _file = [];
      json['file'].forEach((v) {
        _file?.add(File.fromJson(v));
      });
    }
    _price = json['price'];
    _sellingPrice = json['selling_price'];
    _discountedPrice = json['discounted_price'];
    _purchasePrice = json['purchase_price'];
    _batchno = json['batchno'];
    _city = json['city'];
    _commission = json['commission'];
    _packagingCharge = json['packaging_charge'];
    _taxStatus = json['tax_status'];
    _cgst = json['cgst'];
    _sgst = json['sgst'];
    _igst = json['igst'];
    _sku = json['sku'];
    _stockQty = json['stock_qty'];
    _backorders = json['backorders'];
    _threshold = json['threshold'];
    _manageStock = json['manage_stock'];
    _weight = json['weight'];
    _length = json['length'];
    _width = json['width'];
    _height = json['height'];
    _attribute = json['attribute'];
    _tags = json['tags'];
    _startDate = json['start_date'];
    _endDate = json['end_date'];
    _createdDate = json['created_date'];
    _updateDate = json['update_date'];
    _active = json['active'];
    _deal = json['deal'];
    _featured = json['featured'];
    _deleted = json['deleted'];
    _express = json['express'];
    _addedBy = json['added_by'];
    _point = json['point'];
    _stockProduct = json['stock_product'];
    _consumable = json['consumable'];
    _seoTitle = json['seo_title'];
    _seoDescription = json['seo_description'];
    _seoKeywords = json['seo_keywords'];
    _top = json['top'];
    _taste = json['taste'];
    _rating = json['rating'];
    _slugHistory = json['slug_history'] != null ? json['slug_history'].cast<String>() : [];
    _id = json['_id'];
    _pointExpDate = json['point_exp_date'];
    _slug = json['slug'];
    _v = json['__v'];
  }
  dynamic _comboProducts;
  String? _name;
  String? _category;
  String? _subCategory;
  String? _cuisine;
  String? _brand;
  String? _vendor;
  String? _desc;
  String? _shortDesc;
  List<File>? _file;
  num? _price;
  num? _sellingPrice;
  String? _discountedPrice;
  String? _purchasePrice;
  String? _batchno;
  String? _city;
  String? _commission;
  String? _packagingCharge;
  String? _taxStatus;
  String? _cgst;
  String? _sgst;
  String? _igst;
  String? _sku;
  String? _stockQty;
  String? _backorders;
  String? _threshold;
  num? _manageStock;
  String? _weight;
  String? _length;
  String? _width;
  String? _height;
  String? _attribute;
  String? _tags;
  String? _startDate;
  String? _endDate;
  String? _createdDate;
  String? _updateDate;
  num? _active;
  num? _deal;
  num? _featured;
  num? _deleted;
  bool? _express;
  String? _addedBy;
  num? _point;
  String? _stockProduct;
  num? _consumable;
  String? _seoTitle;
  String? _seoDescription;
  String? _seoKeywords;
  num? _top;
  num? _taste;
  String? _rating;
  List<String>? _slugHistory;
  String? _id;
  String? _pointExpDate;
  String? _slug;
  num? _v;
Product copyWith({  dynamic comboProducts,
  String? name,
  String? category,
  String? subCategory,
  String? cuisine,
  String? brand,
  String? vendor,
  String? desc,
  String? shortDesc,
  List<File>? file,
  num? price,
  num? sellingPrice,
  String? discountedPrice,
  String? purchasePrice,
  String? batchno,
  String? city,
  String? commission,
  String? packagingCharge,
  String? taxStatus,
  String? cgst,
  String? sgst,
  String? igst,
  String? sku,
  String? stockQty,
  String? backorders,
  String? threshold,
  num? manageStock,
  String? weight,
  String? length,
  String? width,
  String? height,
  String? attribute,
  String? tags,
  String? startDate,
  String? endDate,
  String? createdDate,
  String? updateDate,
  num? active,
  num? deal,
  num? featured,
  num? deleted,
  bool? express,
  String? addedBy,
  num? point,
  String? stockProduct,
  num? consumable,
  String? seoTitle,
  String? seoDescription,
  String? seoKeywords,
  num? top,
  num? taste,
  String? rating,
  List<String>? slugHistory,
  String? id,
  String? pointExpDate,
  String? slug,
  num? v,
}) => Product(  comboProducts: comboProducts ?? _comboProducts,
  name: name ?? _name,
  category: category ?? _category,
  subCategory: subCategory ?? _subCategory,
  cuisine: cuisine ?? _cuisine,
  brand: brand ?? _brand,
  vendor: vendor ?? _vendor,
  desc: desc ?? _desc,
  shortDesc: shortDesc ?? _shortDesc,
  file: file ?? _file,
  price: price ?? _price,
  sellingPrice: sellingPrice ?? _sellingPrice,
  discountedPrice: discountedPrice ?? _discountedPrice,
  purchasePrice: purchasePrice ?? _purchasePrice,
  batchno: batchno ?? _batchno,
  city: city ?? _city,
  commission: commission ?? _commission,
  packagingCharge: packagingCharge ?? _packagingCharge,
  taxStatus: taxStatus ?? _taxStatus,
  cgst: cgst ?? _cgst,
  sgst: sgst ?? _sgst,
  igst: igst ?? _igst,
  sku: sku ?? _sku,
  stockQty: stockQty ?? _stockQty,
  backorders: backorders ?? _backorders,
  threshold: threshold ?? _threshold,
  manageStock: manageStock ?? _manageStock,
  weight: weight ?? _weight,
  length: length ?? _length,
  width: width ?? _width,
  height: height ?? _height,
  attribute: attribute ?? _attribute,
  tags: tags ?? _tags,
  startDate: startDate ?? _startDate,
  endDate: endDate ?? _endDate,
  createdDate: createdDate ?? _createdDate,
  updateDate: updateDate ?? _updateDate,
  active: active ?? _active,
  deal: deal ?? _deal,
  featured: featured ?? _featured,
  deleted: deleted ?? _deleted,
  express: express ?? _express,
  addedBy: addedBy ?? _addedBy,
  point: point ?? _point,
  stockProduct: stockProduct ?? _stockProduct,
  consumable: consumable ?? _consumable,
  seoTitle: seoTitle ?? _seoTitle,
  seoDescription: seoDescription ?? _seoDescription,
  seoKeywords: seoKeywords ?? _seoKeywords,
  top: top ?? _top,
  taste: taste ?? _taste,
  rating: rating ?? _rating,
  slugHistory: slugHistory ?? _slugHistory,
  id: id ?? _id,
  pointExpDate: pointExpDate ?? _pointExpDate,
  slug: slug ?? _slug,
  v: v ?? _v,
);
  dynamic get comboProducts => _comboProducts;
  String? get name => _name;
  String? get category => _category;
  String? get subCategory => _subCategory;
  String? get cuisine => _cuisine;
  String? get brand => _brand;
  String? get vendor => _vendor;
  String? get desc => _desc;
  String? get shortDesc => _shortDesc;
  List<File>? get file => _file;
  num? get price => _price;
  num? get sellingPrice => _sellingPrice;
  String? get discountedPrice => _discountedPrice;
  String? get purchasePrice => _purchasePrice;
  String? get batchno => _batchno;
  String? get city => _city;
  String? get commission => _commission;
  String? get packagingCharge => _packagingCharge;
  String? get taxStatus => _taxStatus;
  String? get cgst => _cgst;
  String? get sgst => _sgst;
  String? get igst => _igst;
  String? get sku => _sku;
  String? get stockQty => _stockQty;
  String? get backorders => _backorders;
  String? get threshold => _threshold;
  num? get manageStock => _manageStock;
  String? get weight => _weight;
  String? get length => _length;
  String? get width => _width;
  String? get height => _height;
  String? get attribute => _attribute;
  String? get tags => _tags;
  String? get startDate => _startDate;
  String? get endDate => _endDate;
  String? get createdDate => _createdDate;
  String? get updateDate => _updateDate;
  num? get active => _active;
  num? get deal => _deal;
  num? get featured => _featured;
  num? get deleted => _deleted;
  bool? get express => _express;
  String? get addedBy => _addedBy;
  num? get point => _point;
  String? get stockProduct => _stockProduct;
  num? get consumable => _consumable;
  String? get seoTitle => _seoTitle;
  String? get seoDescription => _seoDescription;
  String? get seoKeywords => _seoKeywords;
  num? get top => _top;
  num? get taste => _taste;
  String? get rating => _rating;
  List<String>? get slugHistory => _slugHistory;
  String? get id => _id;
  String? get pointExpDate => _pointExpDate;
  String? get slug => _slug;
  num? get v => _v;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['combo_products'] = _comboProducts;
    map['name'] = _name;
    map['category'] = _category;
    map['sub_category'] = _subCategory;
    map['cuisine'] = _cuisine;
    map['brand'] = _brand;
    map['vendor'] = _vendor;
    map['desc'] = _desc;
    map['short_desc'] = _shortDesc;
    if (_file != null) {
      map['file'] = _file?.map((v) => v.toJson()).toList();
    }
    map['price'] = _price;
    map['selling_price'] = _sellingPrice;
    map['discounted_price'] = _discountedPrice;
    map['purchase_price'] = _purchasePrice;
    map['batchno'] = _batchno;
    map['city'] = _city;
    map['commission'] = _commission;
    map['packaging_charge'] = _packagingCharge;
    map['tax_status'] = _taxStatus;
    map['cgst'] = _cgst;
    map['sgst'] = _sgst;
    map['igst'] = _igst;
    map['sku'] = _sku;
    map['stock_qty'] = _stockQty;
    map['backorders'] = _backorders;
    map['threshold'] = _threshold;
    map['manage_stock'] = _manageStock;
    map['weight'] = _weight;
    map['length'] = _length;
    map['width'] = _width;
    map['height'] = _height;
    map['attribute'] = _attribute;
    map['tags'] = _tags;
    map['start_date'] = _startDate;
    map['end_date'] = _endDate;
    map['created_date'] = _createdDate;
    map['update_date'] = _updateDate;
    map['active'] = _active;
    map['deal'] = _deal;
    map['featured'] = _featured;
    map['deleted'] = _deleted;
    map['express'] = _express;
    map['added_by'] = _addedBy;
    map['point'] = _point;
    map['stock_product'] = _stockProduct;
    map['consumable'] = _consumable;
    map['seo_title'] = _seoTitle;
    map['seo_description'] = _seoDescription;
    map['seo_keywords'] = _seoKeywords;
    map['top'] = _top;
    map['taste'] = _taste;
    map['rating'] = _rating;
    map['slug_history'] = _slugHistory;
    map['_id'] = _id;
    map['point_exp_date'] = _pointExpDate;
    map['slug'] = _slug;
    map['__v'] = _v;
    return map;
  }

}

File fileFromJson(String str) => File.fromJson(json.decode(str));
String fileToJson(File data) => json.encode(data.toJson());
class File {
  File({
      String? fieldname, 
      String? originalname, 
      String? encoding, 
      String? mimetype, 
      num? size, 
      String? bucket, 
      String? key, 
      String? acl, 
      String? contentType, 
      dynamic contentDisposition, 
      dynamic contentEncoding, 
      String? storageClass, 
      dynamic serverSideEncryption, 
      dynamic metadata, 
      String? location, 
      String? etag,}){
    _fieldname = fieldname;
    _originalname = originalname;
    _encoding = encoding;
    _mimetype = mimetype;
    _size = size;
    _bucket = bucket;
    _key = key;
    _acl = acl;
    _contentType = contentType;
    _contentDisposition = contentDisposition;
    _contentEncoding = contentEncoding;
    _storageClass = storageClass;
    _serverSideEncryption = serverSideEncryption;
    _metadata = metadata;
    _location = location;
    _etag = etag;
}

  File.fromJson(dynamic json) {
    _fieldname = json['fieldname'];
    _originalname = json['originalname'];
    _encoding = json['encoding'];
    _mimetype = json['mimetype'];
    _size = json['size'];
    _bucket = json['bucket'];
    _key = json['key'];
    _acl = json['acl'];
    _contentType = json['contentType'];
    _contentDisposition = json['contentDisposition'];
    _contentEncoding = json['contentEncoding'];
    _storageClass = json['storageClass'];
    _serverSideEncryption = json['serverSideEncryption'];
    _metadata = json['metadata'];
    _location = json['location'];
    _etag = json['etag'];
  }
  String? _fieldname;
  String? _originalname;
  String? _encoding;
  String? _mimetype;
  num? _size;
  String? _bucket;
  String? _key;
  String? _acl;
  String? _contentType;
  dynamic _contentDisposition;
  dynamic _contentEncoding;
  String? _storageClass;
  dynamic _serverSideEncryption;
  dynamic _metadata;
  String? _location;
  String? _etag;
File copyWith({  String? fieldname,
  String? originalname,
  String? encoding,
  String? mimetype,
  num? size,
  String? bucket,
  String? key,
  String? acl,
  String? contentType,
  dynamic contentDisposition,
  dynamic contentEncoding,
  String? storageClass,
  dynamic serverSideEncryption,
  dynamic metadata,
  String? location,
  String? etag,
}) => File(  fieldname: fieldname ?? _fieldname,
  originalname: originalname ?? _originalname,
  encoding: encoding ?? _encoding,
  mimetype: mimetype ?? _mimetype,
  size: size ?? _size,
  bucket: bucket ?? _bucket,
  key: key ?? _key,
  acl: acl ?? _acl,
  contentType: contentType ?? _contentType,
  contentDisposition: contentDisposition ?? _contentDisposition,
  contentEncoding: contentEncoding ?? _contentEncoding,
  storageClass: storageClass ?? _storageClass,
  serverSideEncryption: serverSideEncryption ?? _serverSideEncryption,
  metadata: metadata ?? _metadata,
  location: location ?? _location,
  etag: etag ?? _etag,
);
  String? get fieldname => _fieldname;
  String? get originalname => _originalname;
  String? get encoding => _encoding;
  String? get mimetype => _mimetype;
  num? get size => _size;
  String? get bucket => _bucket;
  String? get key => _key;
  String? get acl => _acl;
  String? get contentType => _contentType;
  dynamic get contentDisposition => _contentDisposition;
  dynamic get contentEncoding => _contentEncoding;
  String? get storageClass => _storageClass;
  dynamic get serverSideEncryption => _serverSideEncryption;
  dynamic get metadata => _metadata;
  String? get location => _location;
  String? get etag => _etag;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['fieldname'] = _fieldname;
    map['originalname'] = _originalname;
    map['encoding'] = _encoding;
    map['mimetype'] = _mimetype;
    map['size'] = _size;
    map['bucket'] = _bucket;
    map['key'] = _key;
    map['acl'] = _acl;
    map['contentType'] = _contentType;
    map['contentDisposition'] = _contentDisposition;
    map['contentEncoding'] = _contentEncoding;
    map['storageClass'] = _storageClass;
    map['serverSideEncryption'] = _serverSideEncryption;
    map['metadata'] = _metadata;
    map['location'] = _location;
    map['etag'] = _etag;
    return map;
  }

}

DeliveryPartner deliveryPartnerFromJson(String str) => DeliveryPartner.fromJson(json.decode(str));
String deliveryPartnerToJson(DeliveryPartner data) => json.encode(data.toJson());
class DeliveryPartner {
  DeliveryPartner({
      VendorPosition? vendorPosition, 
      CargoPosition? cargoPosition, 
      DeliveryPartnerPosition? deliveryPartnerPosition, 
      Subscription? subscription, 
      String? fullName, 
      String? email, 
      String? password, 
      String? mobile, 
      String? userType, 
      num? otp, 
      num? emailOtp, 
      String? updateDate, 
      String? profileImage, 
      num? active, 
      num? loginActive, 
      num? deleted, 
      String? address, 
      dynamic city, 
      dynamic cod, 
      List<String>? customerSupportCity, 
      List<dynamic>? deliveryCity, 
      String? pricePerKg, 
      String? pricePerPack, 
      String? ratePerKm, 
      String? monthlyFixedCost, 
      String? communicationZipcode, 
      String? serviceZipcode, 
      String? bankName, 
      String? accHolderName, 
      String? accNumber, 
      String? branchCode, 
      String? ifsc, 
      String? bankAddress, 
      dynamic master, 
      String? slug, 
      String? about, 
      String? note, 
      String? commissionType, 
      String? commission, 
      String? file, 
      String? seoTitle, 
      String? seoDesc, 
      dynamic deviceToken, 
      dynamic deviceType, 
      List<dynamic>? lpManager, 
      List<dynamic>? deliveryBoy,
      String? doc1Type, 
      String? doc1, 
      String? doc2Type, 
      String? doc2, 
      String? doc3Type, 
      String? doc3, 
      num? codOrderCost, 
      num? additionalCost1, 
      num? additionalCost2, 
      String? refferBy, 
      num? firstTime, 
      dynamic office, 
      String? salary, 
      String? fatherName, 
      String? presentAddress, 
      String? country, 
      String? city2, 
      String? state, 
      String? zipcode, 
      String? healthInsuranceNumber, 
      String? aadhar, 
      String? pan, 
      dynamic dateOfJoin, 
      dynamic dateOfReleiving, 
      String? post, 
      List<dynamic>? bagNo, 
      dynamic role, 
      String? pricePerKmWithoutOrder, 
      String? id, 
      String? createdDate, 
      num? v, 
      String? updatedAt,}){
    _vendorPosition = vendorPosition;
    _cargoPosition = cargoPosition;
    _deliveryPartnerPosition = deliveryPartnerPosition;
    _subscription = subscription;
    _fullName = fullName;
    _email = email;
    _password = password;
    _mobile = mobile;
    _userType = userType;
    _otp = otp;
    _emailOtp = emailOtp;
    _updateDate = updateDate;
    _profileImage = profileImage;
    _active = active;
    _loginActive = loginActive;
    _deleted = deleted;
    _address = address;
    _city = city;
    _cod = cod;
    _customerSupportCity = customerSupportCity;
    _deliveryCity = deliveryCity;
    _pricePerKg = pricePerKg;
    _pricePerPack = pricePerPack;
    _ratePerKm = ratePerKm;
    _monthlyFixedCost = monthlyFixedCost;
    _communicationZipcode = communicationZipcode;
    _serviceZipcode = serviceZipcode;
    _bankName = bankName;
    _accHolderName = accHolderName;
    _accNumber = accNumber;
    _branchCode = branchCode;
    _ifsc = ifsc;
    _bankAddress = bankAddress;
    _master = master;
    _slug = slug;
    _about = about;
    _note = note;
    _commissionType = commissionType;
    _commission = commission;
    _file = file;
    _seoTitle = seoTitle;
    _seoDesc = seoDesc;
    _deviceToken = deviceToken;
    _deviceType = deviceType;
    _lpManager = lpManager;
    _deliveryBoy = deliveryBoy;
    _doc1Type = doc1Type;
    _doc1 = doc1;
    _doc2Type = doc2Type;
    _doc2 = doc2;
    _doc3Type = doc3Type;
    _doc3 = doc3;
    _codOrderCost = codOrderCost;
    _additionalCost1 = additionalCost1;
    _additionalCost2 = additionalCost2;
    _refferBy = refferBy;
    _firstTime = firstTime;
    _office = office;
    _salary = salary;
    _fatherName = fatherName;
    _presentAddress = presentAddress;
    _country = country;
    _city2 = city2;
    _state = state;
    _zipcode = zipcode;
    _healthInsuranceNumber = healthInsuranceNumber;
    _aadhar = aadhar;
    _pan = pan;
    _dateOfJoin = dateOfJoin;
    _dateOfReleiving = dateOfReleiving;
    _post = post;
    _bagNo = bagNo;
    _role = role;
    _pricePerKmWithoutOrder = pricePerKmWithoutOrder;
    _id = id;
    _createdDate = createdDate;
    _v = v;
    _updatedAt = updatedAt;
}

  DeliveryPartner.fromJson(dynamic json) {
    _vendorPosition = json['vendor_position'] != null ? VendorPosition.fromJson(json['vendor_position']) : null;
    _cargoPosition = json['cargo_position'] != null ? CargoPosition.fromJson(json['cargo_position']) : null;
    _deliveryPartnerPosition = json['delivery_partner_position'] != null ? DeliveryPartnerPosition.fromJson(json['delivery_partner_position']) : null;
    _subscription = json['subscription'] != null ? Subscription.fromJson(json['subscription']) : null;
    _fullName = json['full_name'];
    _email = json['email'];
    _password = json['password'];
    _mobile = json['mobile'];
    _userType = json['user_type'];
    _otp = json['otp'];
    _emailOtp = json['email_otp'];
    _updateDate = json['update_date'];
    _profileImage = json['profile_image'];
    _active = json['active'];
    _loginActive = json['login_active'];
    _deleted = json['deleted'];
    _address = json['address'];
    _city = json['city'];
    _cod = json['cod'];
    _customerSupportCity = json['customer_support_city'] != null ? json['customer_support_city'].cast<String>() : [];
    if (json['delivery_city'] != null) {
      _deliveryCity = [];
      json['delivery_city'].forEach((v) {
        _deliveryCity?.add(v);
      });
    }
    _pricePerKg = json['price_per_kg'];
    _pricePerPack = json['price_per_pack'];
    _ratePerKm = json['rate_per_km'];
    _monthlyFixedCost = json['monthly_fixed_cost'];
    _communicationZipcode = json['communication_zipcode'];
    _serviceZipcode = json['service_zipcode'];
    _bankName = json['bank_name'];
    _accHolderName = json['acc_holder_name'];
    _accNumber = json['acc_number'];
    _branchCode = json['branch_code'];
    _ifsc = json['ifsc'];
    _bankAddress = json['bank_address'];
    _master = json['master'];
    _slug = json['slug'];
    _about = json['about'];
    _note = json['note'];
    _commissionType = json['commission_type'];
    _commission = json['commission'];
    _file = json['file'];
    _seoTitle = json['seo_title'];
    _seoDesc = json['seo_desc'];
    _deviceToken = json['device_token'];
    _deviceType = json['device_type'];
    if (json['lp_manager'] != null) {
      _lpManager = [];
      json['lp_manager'].forEach((v) {
        _lpManager?.add(v);
      });
    }
    if (json['delivery_boy'] != null) {
      _deliveryBoy = [];
      json['delivery_boy'].forEach((v) {
        _deliveryBoy?.add(v);
      });
    }
    _doc1Type = json['doc1_type'];
    _doc1 = json['doc1'];
    _doc2Type = json['doc2_type'];
    _doc2 = json['doc2'];
    _doc3Type = json['doc3_type'];
    _doc3 = json['doc3'];
    _codOrderCost = json['cod_order_cost'];
    _additionalCost1 = json['additional_cost1'];
    _additionalCost2 = json['additional_cost2'];
    _refferBy = json['reffer_by'];
    _firstTime = json['first_time'];
    _office = json['office'];
    _salary = json['salary'];
    _fatherName = json['father_name'];
    _presentAddress = json['present_address'];
    _country = json['country'];
    _city2 = json['city2'];
    _state = json['state'];
    _zipcode = json['zipcode'];
    _healthInsuranceNumber = json['health_insurance_number'];
    _aadhar = json['aadhar'];
    _pan = json['pan'];
    _dateOfJoin = json['date_of_join'];
    _dateOfReleiving = json['date_of_releiving'];
    _post = json['post'];
    if (json['bag_no'] != null) {
      _bagNo = [];
      json['bag_no'].forEach((v) {
        _bagNo?.add(v);
      });
    }
    _role = json['role'];
    _pricePerKmWithoutOrder = json['price_per_km_without_order'];
    _id = json['_id'];
    _createdDate = json['created_date'];
    _v = json['__v'];
    _updatedAt = json['updatedAt'];
  }
  VendorPosition? _vendorPosition;
  CargoPosition? _cargoPosition;
  DeliveryPartnerPosition? _deliveryPartnerPosition;
  Subscription? _subscription;
  String? _fullName;
  String? _email;
  String? _password;
  String? _mobile;
  String? _userType;
  num? _otp;
  num? _emailOtp;
  String? _updateDate;
  String? _profileImage;
  num? _active;
  num? _loginActive;
  num? _deleted;
  String? _address;
  dynamic _city;
  dynamic _cod;
  List<String>? _customerSupportCity;
  List<dynamic>? _deliveryCity;
  String? _pricePerKg;
  String? _pricePerPack;
  String? _ratePerKm;
  String? _monthlyFixedCost;
  String? _communicationZipcode;
  String? _serviceZipcode;
  String? _bankName;
  String? _accHolderName;
  String? _accNumber;
  String? _branchCode;
  String? _ifsc;
  String? _bankAddress;
  dynamic _master;
  String? _slug;
  String? _about;
  String? _note;
  String? _commissionType;
  String? _commission;
  String? _file;
  String? _seoTitle;
  String? _seoDesc;
  dynamic _deviceToken;
  dynamic _deviceType;
  List<dynamic>? _lpManager;
  List<dynamic>? _deliveryBoy;
  String? _doc1Type;
  String? _doc1;
  String? _doc2Type;
  String? _doc2;
  String? _doc3Type;
  String? _doc3;
  num? _codOrderCost;
  num? _additionalCost1;
  num? _additionalCost2;
  String? _refferBy;
  num? _firstTime;
  dynamic _office;
  String? _salary;
  String? _fatherName;
  String? _presentAddress;
  String? _country;
  String? _city2;
  String? _state;
  String? _zipcode;
  String? _healthInsuranceNumber;
  String? _aadhar;
  String? _pan;
  dynamic _dateOfJoin;
  dynamic _dateOfReleiving;
  String? _post;
  List<dynamic>? _bagNo;
  dynamic _role;
  String? _pricePerKmWithoutOrder;
  String? _id;
  String? _createdDate;
  num? _v;
  String? _updatedAt;
DeliveryPartner copyWith({  VendorPosition? vendorPosition,
  CargoPosition? cargoPosition,
  DeliveryPartnerPosition? deliveryPartnerPosition,
  Subscription? subscription,
  String? fullName,
  String? email,
  String? password,
  String? mobile,
  String? userType,
  num? otp,
  num? emailOtp,
  String? updateDate,
  String? profileImage,
  num? active,
  num? loginActive,
  num? deleted,
  String? address,
  dynamic city,
  dynamic cod,
  List<String>? customerSupportCity,
  List<dynamic>? deliveryCity,
  String? pricePerKg,
  String? pricePerPack,
  String? ratePerKm,
  String? monthlyFixedCost,
  String? communicationZipcode,
  String? serviceZipcode,
  String? bankName,
  String? accHolderName,
  String? accNumber,
  String? branchCode,
  String? ifsc,
  String? bankAddress,
  dynamic master,
  String? slug,
  String? about,
  String? note,
  String? commissionType,
  String? commission,
  String? file,
  String? seoTitle,
  String? seoDesc,
  dynamic deviceToken,
  dynamic deviceType,
  List<dynamic>? lpManager,
  List<dynamic>? deliveryBoy,
  String? doc1Type,
  String? doc1,
  String? doc2Type,
  String? doc2,
  String? doc3Type,
  String? doc3,
  num? codOrderCost,
  num? additionalCost1,
  num? additionalCost2,
  String? refferBy,
  num? firstTime,
  dynamic office,
  String? salary,
  String? fatherName,
  String? presentAddress,
  String? country,
  String? city2,
  String? state,
  String? zipcode,
  String? healthInsuranceNumber,
  String? aadhar,
  String? pan,
  dynamic dateOfJoin,
  dynamic dateOfReleiving,
  String? post,
  List<dynamic>? bagNo,
  dynamic role,
  String? pricePerKmWithoutOrder,
  String? id,
  String? createdDate,
  num? v,
  String? updatedAt,
}) => DeliveryPartner(  vendorPosition: vendorPosition ?? _vendorPosition,
  cargoPosition: cargoPosition ?? _cargoPosition,
  deliveryPartnerPosition: deliveryPartnerPosition ?? _deliveryPartnerPosition,
  subscription: subscription ?? _subscription,
  fullName: fullName ?? _fullName,
  email: email ?? _email,
  password: password ?? _password,
  mobile: mobile ?? _mobile,
  userType: userType ?? _userType,
  otp: otp ?? _otp,
  emailOtp: emailOtp ?? _emailOtp,
  updateDate: updateDate ?? _updateDate,
  profileImage: profileImage ?? _profileImage,
  active: active ?? _active,
  loginActive: loginActive ?? _loginActive,
  deleted: deleted ?? _deleted,
  address: address ?? _address,
  city: city ?? _city,
  cod: cod ?? _cod,
  customerSupportCity: customerSupportCity ?? _customerSupportCity,
  deliveryCity: deliveryCity ?? _deliveryCity,
  pricePerKg: pricePerKg ?? _pricePerKg,
  pricePerPack: pricePerPack ?? _pricePerPack,
  ratePerKm: ratePerKm ?? _ratePerKm,
  monthlyFixedCost: monthlyFixedCost ?? _monthlyFixedCost,
  communicationZipcode: communicationZipcode ?? _communicationZipcode,
  serviceZipcode: serviceZipcode ?? _serviceZipcode,
  bankName: bankName ?? _bankName,
  accHolderName: accHolderName ?? _accHolderName,
  accNumber: accNumber ?? _accNumber,
  branchCode: branchCode ?? _branchCode,
  ifsc: ifsc ?? _ifsc,
  bankAddress: bankAddress ?? _bankAddress,
  master: master ?? _master,
  slug: slug ?? _slug,
  about: about ?? _about,
  note: note ?? _note,
  commissionType: commissionType ?? _commissionType,
  commission: commission ?? _commission,
  file: file ?? _file,
  seoTitle: seoTitle ?? _seoTitle,
  seoDesc: seoDesc ?? _seoDesc,
  deviceToken: deviceToken ?? _deviceToken,
  deviceType: deviceType ?? _deviceType,
  lpManager: lpManager ?? _lpManager,
  deliveryBoy: deliveryBoy ?? _deliveryBoy,
  doc1Type: doc1Type ?? _doc1Type,
  doc1: doc1 ?? _doc1,
  doc2Type: doc2Type ?? _doc2Type,
  doc2: doc2 ?? _doc2,
  doc3Type: doc3Type ?? _doc3Type,
  doc3: doc3 ?? _doc3,
  codOrderCost: codOrderCost ?? _codOrderCost,
  additionalCost1: additionalCost1 ?? _additionalCost1,
  additionalCost2: additionalCost2 ?? _additionalCost2,
  refferBy: refferBy ?? _refferBy,
  firstTime: firstTime ?? _firstTime,
  office: office ?? _office,
  salary: salary ?? _salary,
  fatherName: fatherName ?? _fatherName,
  presentAddress: presentAddress ?? _presentAddress,
  country: country ?? _country,
  city2: city2 ?? _city2,
  state: state ?? _state,
  zipcode: zipcode ?? _zipcode,
  healthInsuranceNumber: healthInsuranceNumber ?? _healthInsuranceNumber,
  aadhar: aadhar ?? _aadhar,
  pan: pan ?? _pan,
  dateOfJoin: dateOfJoin ?? _dateOfJoin,
  dateOfReleiving: dateOfReleiving ?? _dateOfReleiving,
  post: post ?? _post,
  bagNo: bagNo ?? _bagNo,
  role: role ?? _role,
  pricePerKmWithoutOrder: pricePerKmWithoutOrder ?? _pricePerKmWithoutOrder,
  id: id ?? _id,
  createdDate: createdDate ?? _createdDate,
  v: v ?? _v,
  updatedAt: updatedAt ?? _updatedAt,
);
  VendorPosition? get vendorPosition => _vendorPosition;
  CargoPosition? get cargoPosition => _cargoPosition;
  DeliveryPartnerPosition? get deliveryPartnerPosition => _deliveryPartnerPosition;
  Subscription? get subscription => _subscription;
  String? get fullName => _fullName;
  String? get email => _email;
  String? get password => _password;
  String? get mobile => _mobile;
  String? get userType => _userType;
  num? get otp => _otp;
  num? get emailOtp => _emailOtp;
  String? get updateDate => _updateDate;
  String? get profileImage => _profileImage;
  num? get active => _active;
  num? get loginActive => _loginActive;
  num? get deleted => _deleted;
  String? get address => _address;
  dynamic get city => _city;
  dynamic get cod => _cod;
  List<String>? get customerSupportCity => _customerSupportCity;
  List<dynamic>? get deliveryCity => _deliveryCity;
  String? get pricePerKg => _pricePerKg;
  String? get pricePerPack => _pricePerPack;
  String? get ratePerKm => _ratePerKm;
  String? get monthlyFixedCost => _monthlyFixedCost;
  String? get communicationZipcode => _communicationZipcode;
  String? get serviceZipcode => _serviceZipcode;
  String? get bankName => _bankName;
  String? get accHolderName => _accHolderName;
  String? get accNumber => _accNumber;
  String? get branchCode => _branchCode;
  String? get ifsc => _ifsc;
  String? get bankAddress => _bankAddress;
  dynamic get master => _master;
  String? get slug => _slug;
  String? get about => _about;
  String? get note => _note;
  String? get commissionType => _commissionType;
  String? get commission => _commission;
  String? get file => _file;
  String? get seoTitle => _seoTitle;
  String? get seoDesc => _seoDesc;
  dynamic get deviceToken => _deviceToken;
  dynamic get deviceType => _deviceType;
  List<dynamic>? get lpManager => _lpManager;
  List<dynamic>? get deliveryBoy => _deliveryBoy;
  String? get doc1Type => _doc1Type;
  String? get doc1 => _doc1;
  String? get doc2Type => _doc2Type;
  String? get doc2 => _doc2;
  String? get doc3Type => _doc3Type;
  String? get doc3 => _doc3;
  num? get codOrderCost => _codOrderCost;
  num? get additionalCost1 => _additionalCost1;
  num? get additionalCost2 => _additionalCost2;
  String? get refferBy => _refferBy;
  num? get firstTime => _firstTime;
  dynamic get office => _office;
  String? get salary => _salary;
  String? get fatherName => _fatherName;
  String? get presentAddress => _presentAddress;
  String? get country => _country;
  String? get city2 => _city2;
  String? get state => _state;
  String? get zipcode => _zipcode;
  String? get healthInsuranceNumber => _healthInsuranceNumber;
  String? get aadhar => _aadhar;
  String? get pan => _pan;
  dynamic get dateOfJoin => _dateOfJoin;
  dynamic get dateOfReleiving => _dateOfReleiving;
  String? get post => _post;
  List<dynamic>? get bagNo => _bagNo;
  dynamic get role => _role;
  String? get pricePerKmWithoutOrder => _pricePerKmWithoutOrder;
  String? get id => _id;
  String? get createdDate => _createdDate;
  num? get v => _v;
  String? get updatedAt => _updatedAt;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (_vendorPosition != null) {
      map['vendor_position'] = _vendorPosition?.toJson();
    }
    if (_cargoPosition != null) {
      map['cargo_position'] = _cargoPosition?.toJson();
    }
    if (_deliveryPartnerPosition != null) {
      map['delivery_partner_position'] = _deliveryPartnerPosition?.toJson();
    }
    if (_subscription != null) {
      map['subscription'] = _subscription?.toJson();
    }
    map['full_name'] = _fullName;
    map['email'] = _email;
    map['password'] = _password;
    map['mobile'] = _mobile;
    map['user_type'] = _userType;
    map['otp'] = _otp;
    map['email_otp'] = _emailOtp;
    map['update_date'] = _updateDate;
    map['profile_image'] = _profileImage;
    map['active'] = _active;
    map['login_active'] = _loginActive;
    map['deleted'] = _deleted;
    map['address'] = _address;
    map['city'] = _city;
    map['cod'] = _cod;
    map['customer_support_city'] = _customerSupportCity;
    if (_deliveryCity != null) {
      map['delivery_city'] = _deliveryCity?.map((v) => v.toJson()).toList();
    }
    map['price_per_kg'] = _pricePerKg;
    map['price_per_pack'] = _pricePerPack;
    map['rate_per_km'] = _ratePerKm;
    map['monthly_fixed_cost'] = _monthlyFixedCost;
    map['communication_zipcode'] = _communicationZipcode;
    map['service_zipcode'] = _serviceZipcode;
    map['bank_name'] = _bankName;
    map['acc_holder_name'] = _accHolderName;
    map['acc_number'] = _accNumber;
    map['branch_code'] = _branchCode;
    map['ifsc'] = _ifsc;
    map['bank_address'] = _bankAddress;
    map['master'] = _master;
    map['slug'] = _slug;
    map['about'] = _about;
    map['note'] = _note;
    map['commission_type'] = _commissionType;
    map['commission'] = _commission;
    map['file'] = _file;
    map['seo_title'] = _seoTitle;
    map['seo_desc'] = _seoDesc;
    map['device_token'] = _deviceToken;
    map['device_type'] = _deviceType;
    if (_lpManager != null) {
      map['lp_manager'] = _lpManager?.map((v) => v.toJson()).toList();
    }
    if (_deliveryBoy != null) {
      map['delivery_boy'] = _deliveryBoy?.map((v) => v.toJson()).toList();
    }
    map['doc1_type'] = _doc1Type;
    map['doc1'] = _doc1;
    map['doc2_type'] = _doc2Type;
    map['doc2'] = _doc2;
    map['doc3_type'] = _doc3Type;
    map['doc3'] = _doc3;
    map['cod_order_cost'] = _codOrderCost;
    map['additional_cost1'] = _additionalCost1;
    map['additional_cost2'] = _additionalCost2;
    map['reffer_by'] = _refferBy;
    map['first_time'] = _firstTime;
    map['office'] = _office;
    map['salary'] = _salary;
    map['father_name'] = _fatherName;
    map['present_address'] = _presentAddress;
    map['country'] = _country;
    map['city2'] = _city2;
    map['state'] = _state;
    map['zipcode'] = _zipcode;
    map['health_insurance_number'] = _healthInsuranceNumber;
    map['aadhar'] = _aadhar;
    map['pan'] = _pan;
    map['date_of_join'] = _dateOfJoin;
    map['date_of_releiving'] = _dateOfReleiving;
    map['post'] = _post;
    if (_bagNo != null) {
      map['bag_no'] = _bagNo?.map((v) => v.toJson()).toList();
    }
    map['role'] = _role;
    map['price_per_km_without_order'] = _pricePerKmWithoutOrder;
    map['_id'] = _id;
    map['created_date'] = _createdDate;
    map['__v'] = _v;
    map['updatedAt'] = _updatedAt;
    return map;
  }

}

Subscription subscriptionFromJson(String str) => Subscription.fromJson(json.decode(str));
String subscriptionToJson(Subscription data) => json.encode(data.toJson());
class Subscription {
  Subscription({
      dynamic plan, 
      dynamic expDate, 
      num? point, 
      String? key, 
      dynamic updated,}){
    _plan = plan;
    _expDate = expDate;
    _point = point;
    _key = key;
    _updated = updated;
}

  Subscription.fromJson(dynamic json) {
    _plan = json['plan'];
    _expDate = json['exp_date'];
    _point = json['point'];
    _key = json['key'];
    _updated = json['updated'];
  }
  dynamic _plan;
  dynamic _expDate;
  num? _point;
  String? _key;
  dynamic _updated;
Subscription copyWith({  dynamic plan,
  dynamic expDate,
  num? point,
  String? key,
  dynamic updated,
}) => Subscription(  plan: plan ?? _plan,
  expDate: expDate ?? _expDate,
  point: point ?? _point,
  key: key ?? _key,
  updated: updated ?? _updated,
);
  dynamic get plan => _plan;
  dynamic get expDate => _expDate;
  num? get point => _point;
  String? get key => _key;
  dynamic get updated => _updated;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['plan'] = _plan;
    map['exp_date'] = _expDate;
    map['point'] = _point;
    map['key'] = _key;
    map['updated'] = _updated;
    return map;
  }

}

DeliveryPartnerPosition deliveryPartnerPositionFromJson(String str) => DeliveryPartnerPosition.fromJson(json.decode(str));
String deliveryPartnerPositionToJson(DeliveryPartnerPosition data) => json.encode(data.toJson());
class DeliveryPartnerPosition {
  DeliveryPartnerPosition({
      String? type, 
      List<num>? coordinates,}){
    _type = type;
    _coordinates = coordinates;
}

  DeliveryPartnerPosition.fromJson(dynamic json) {
    _type = json['type'];
    _coordinates = json['coordinates'] != null ? json['coordinates'].cast<num>() : [];
  }
  String? _type;
  List<num>? _coordinates;
DeliveryPartnerPosition copyWith({  String? type,
  List<num>? coordinates,
}) => DeliveryPartnerPosition(  type: type ?? _type,
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

CargoPosition cargoPositionFromJson(String str) => CargoPosition.fromJson(json.decode(str));
String cargoPositionToJson(CargoPosition data) => json.encode(data.toJson());
class CargoPosition {
  CargoPosition({
      String? type, 
      List<num>? coordinates,}){
    _type = type;
    _coordinates = coordinates;
}

  CargoPosition.fromJson(dynamic json) {
    _type = json['type'];
    _coordinates = json['coordinates'] != null ? json['coordinates'].cast<num>() : [];
  }
  String? _type;
  List<num>? _coordinates;
CargoPosition copyWith({  String? type,
  List<num>? coordinates,
}) => CargoPosition(  type: type ?? _type,
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


CargoPartner cargoPartnerFromJson(String str) => CargoPartner.fromJson(json.decode(str));
String cargoPartnerToJson(CargoPartner data) => json.encode(data.toJson());
class CargoPartner {
  CargoPartner({
      VendorPosition? vendorPosition,
      CargoPosition? cargoPosition,
      DeliveryPartnerPosition? deliveryPartnerPosition,
      Subscription? subscription,
      String? fullName,
      String? email,
      String? password,
      String? mobile,
      String? userType,
      num? otp,
      num? emailOtp,
      String? updateDate,
      String? profileImage,
      num? active,
      num? loginActive,
      num? deleted,
      String? address,
      dynamic city,
      dynamic cod,
      List<String>? customerSupportCity,
      List<dynamic>? deliveryCity,
      String? pricePerKg,
      String? pricePerPack,
      String? ratePerKm,
      String? monthlyFixedCost,
      String? communicationZipcode,
      String? serviceZipcode,
      String? bankName,
      String? accHolderName,
      String? accNumber,
      String? branchCode,
      String? ifsc,
      String? bankAddress,
      dynamic master,
      String? slug,
      String? about,
      String? note,
      String? commissionType,
      String? commission,
      String? file,
      String? seoTitle,
      String? seoDesc,
      String? deviceToken,
      String? deviceType,
      List<dynamic>? lpManager,
      List<dynamic>? deliveryBoy,
      String? doc1Type,
      String? doc1,
      String? doc2Type,
      String? doc2,
      String? doc3Type,
      String? doc3,
      num? codOrderCost,
      num? additionalCost1,
      num? additionalCost2,
      String? refferBy,
      num? firstTime,
      dynamic office,
      String? salary,
      String? fatherName,
      String? presentAddress,
      String? country,
      String? city2,
      String? state,
      String? zipcode,
      String? healthInsuranceNumber,
      String? aadhar,
      String? pan,
      dynamic dateOfJoin,
      dynamic dateOfReleiving,
      String? post,
      List<dynamic>? bagNo,
      dynamic role,
      String? pricePerKmWithoutOrder,
      String? id,
      String? createdDate,
      num? v,}){
    _vendorPosition = vendorPosition;
    _cargoPosition = cargoPosition;
    _deliveryPartnerPosition = deliveryPartnerPosition;
    _subscription = subscription;
    _fullName = fullName;
    _email = email;
    _password = password;
    _mobile = mobile;
    _userType = userType;
    _otp = otp;
    _emailOtp = emailOtp;
    _updateDate = updateDate;
    _profileImage = profileImage;
    _active = active;
    _loginActive = loginActive;
    _deleted = deleted;
    _address = address;
    _city = city;
    _cod = cod;
    _customerSupportCity = customerSupportCity;
    _deliveryCity = deliveryCity;
    _pricePerKg = pricePerKg;
    _pricePerPack = pricePerPack;
    _ratePerKm = ratePerKm;
    _monthlyFixedCost = monthlyFixedCost;
    _communicationZipcode = communicationZipcode;
    _serviceZipcode = serviceZipcode;
    _bankName = bankName;
    _accHolderName = accHolderName;
    _accNumber = accNumber;
    _branchCode = branchCode;
    _ifsc = ifsc;
    _bankAddress = bankAddress;
    _master = master;
    _slug = slug;
    _about = about;
    _note = note;
    _commissionType = commissionType;
    _commission = commission;
    _file = file;
    _seoTitle = seoTitle;
    _seoDesc = seoDesc;
    _deviceToken = deviceToken;
    _deviceType = deviceType;
    _lpManager = lpManager;
    _deliveryBoy = deliveryBoy;
    _doc1Type = doc1Type;
    _doc1 = doc1;
    _doc2Type = doc2Type;
    _doc2 = doc2;
    _doc3Type = doc3Type;
    _doc3 = doc3;
    _codOrderCost = codOrderCost;
    _additionalCost1 = additionalCost1;
    _additionalCost2 = additionalCost2;
    _refferBy = refferBy;
    _firstTime = firstTime;
    _office = office;
    _salary = salary;
    _fatherName = fatherName;
    _presentAddress = presentAddress;
    _country = country;
    _city2 = city2;
    _state = state;
    _zipcode = zipcode;
    _healthInsuranceNumber = healthInsuranceNumber;
    _aadhar = aadhar;
    _pan = pan;
    _dateOfJoin = dateOfJoin;
    _dateOfReleiving = dateOfReleiving;
    _post = post;
    _bagNo = bagNo;
    _role = role;
    _pricePerKmWithoutOrder = pricePerKmWithoutOrder;
    _id = id;
    _createdDate = createdDate;
    _v = v;
}

  CargoPartner.fromJson(dynamic json) {
    _vendorPosition = json['vendor_position'] != null ? VendorPosition.fromJson(json['vendor_position']) : null;
    _cargoPosition = json['cargo_position'] != null ? CargoPosition.fromJson(json['cargo_position']) : null;
    _deliveryPartnerPosition = json['delivery_partner_position'] != null ? DeliveryPartnerPosition.fromJson(json['delivery_partner_position']) : null;
    _subscription = json['subscription'] != null ? Subscription.fromJson(json['subscription']) : null;
    _fullName = json['full_name'];
    _email = json['email'];
    _password = json['password'];
    _mobile = json['mobile'];
    _userType = json['user_type'];
    _otp = json['otp'];
    _emailOtp = json['email_otp'];
    _updateDate = json['update_date'];
    _profileImage = json['profile_image'];
    _active = json['active'];
    _loginActive = json['login_active'];
    _deleted = json['deleted'];
    _address = json['address'];
    _city = json['city'];
    _cod = json['cod'];
    _customerSupportCity = json['customer_support_city'] != null ? json['customer_support_city'].cast<String>() : [];
    if (json['delivery_city'] != null) {
      _deliveryCity = [];
      json['delivery_city'].forEach((v) {
        _deliveryCity?.add(v);
      });
    }
    _pricePerKg = json['price_per_kg'];
    _pricePerPack = json['price_per_pack'];
    _ratePerKm = json['rate_per_km'];
    _monthlyFixedCost = json['monthly_fixed_cost'];
    _communicationZipcode = json['communication_zipcode'];
    _serviceZipcode = json['service_zipcode'];
    _bankName = json['bank_name'];
    _accHolderName = json['acc_holder_name'];
    _accNumber = json['acc_number'];
    _branchCode = json['branch_code'];
    _ifsc = json['ifsc'];
    _bankAddress = json['bank_address'];
    _master = json['master'];
    _slug = json['slug'];
    _about = json['about'];
    _note = json['note'];
    _commissionType = json['commission_type'];
    _commission = json['commission'];
    _file = json['file'];
    _seoTitle = json['seo_title'];
    _seoDesc = json['seo_desc'];
    _deviceToken = json['device_token'];
    _deviceType = json['device_type'];
    if (json['lp_manager'] != null) {
      _lpManager = [];
      json['lp_manager'].forEach((v) {
        _lpManager?.add(v);
      });
    }
    if (json['delivery_boy'] != null) {
      _deliveryBoy = [];
      json['delivery_boy'].forEach((v) {
        _deliveryBoy?.add(v);
      });
    }
    _doc1Type = json['doc1_type'];
    _doc1 = json['doc1'];
    _doc2Type = json['doc2_type'];
    _doc2 = json['doc2'];
    _doc3Type = json['doc3_type'];
    _doc3 = json['doc3'];
    _codOrderCost = json['cod_order_cost'];
    _additionalCost1 = json['additional_cost1'];
    _additionalCost2 = json['additional_cost2'];
    _refferBy = json['reffer_by'];
    _firstTime = json['first_time'];
    _office = json['office'];
    _salary = json['salary'];
    _fatherName = json['father_name'];
    _presentAddress = json['present_address'];
    _country = json['country'];
    _city2 = json['city2'];
    _state = json['state'];
    _zipcode = json['zipcode'];
    _healthInsuranceNumber = json['health_insurance_number'];
    _aadhar = json['aadhar'];
    _pan = json['pan'];
    _dateOfJoin = json['date_of_join'];
    _dateOfReleiving = json['date_of_releiving'];
    _post = json['post'];
    if (json['bag_no'] != null) {
      _bagNo = [];
      json['bag_no'].forEach((v) {
        _bagNo?.add(v);
      });
    }
    _role = json['role'];
    _pricePerKmWithoutOrder = json['price_per_km_without_order'];
    _id = json['_id'];
    _createdDate = json['created_date'];
    _v = json['__v'];
  }
  VendorPosition? _vendorPosition;
  CargoPosition? _cargoPosition;
  DeliveryPartnerPosition? _deliveryPartnerPosition;
  Subscription? _subscription;
  String? _fullName;
  String? _email;
  String? _password;
  String? _mobile;
  String? _userType;
  num? _otp;
  num? _emailOtp;
  String? _updateDate;
  String? _profileImage;
  num? _active;
  num? _loginActive;
  num? _deleted;
  String? _address;
  dynamic _city;
  dynamic _cod;
  List<String>? _customerSupportCity;
  List<dynamic>? _deliveryCity;
  String? _pricePerKg;
  String? _pricePerPack;
  String? _ratePerKm;
  String? _monthlyFixedCost;
  String? _communicationZipcode;
  String? _serviceZipcode;
  String? _bankName;
  String? _accHolderName;
  String? _accNumber;
  String? _branchCode;
  String? _ifsc;
  String? _bankAddress;
  dynamic _master;
  String? _slug;
  String? _about;
  String? _note;
  String? _commissionType;
  String? _commission;
  String? _file;
  String? _seoTitle;
  String? _seoDesc;
  String? _deviceToken;
  String? _deviceType;
  List<dynamic>? _lpManager;
  List<dynamic>? _deliveryBoy;
  String? _doc1Type;
  String? _doc1;
  String? _doc2Type;
  String? _doc2;
  String? _doc3Type;
  String? _doc3;
  num? _codOrderCost;
  num? _additionalCost1;
  num? _additionalCost2;
  String? _refferBy;
  num? _firstTime;
  dynamic _office;
  String? _salary;
  String? _fatherName;
  String? _presentAddress;
  String? _country;
  String? _city2;
  String? _state;
  String? _zipcode;
  String? _healthInsuranceNumber;
  String? _aadhar;
  String? _pan;
  dynamic _dateOfJoin;
  dynamic _dateOfReleiving;
  String? _post;
  List<dynamic>? _bagNo;
  dynamic _role;
  String? _pricePerKmWithoutOrder;
  String? _id;
  String? _createdDate;
  num? _v;
CargoPartner copyWith({  VendorPosition? vendorPosition,
  CargoPosition? cargoPosition,
  DeliveryPartnerPosition? deliveryPartnerPosition,
  Subscription? subscription,
  String? fullName,
  String? email,
  String? password,
  String? mobile,
  String? userType,
  num? otp,
  num? emailOtp,
  String? updateDate,
  String? profileImage,
  num? active,
  num? loginActive,
  num? deleted,
  String? address,
  dynamic city,
  dynamic cod,
  List<String>? customerSupportCity,
  List<dynamic>? deliveryCity,
  String? pricePerKg,
  String? pricePerPack,
  String? ratePerKm,
  String? monthlyFixedCost,
  String? communicationZipcode,
  String? serviceZipcode,
  String? bankName,
  String? accHolderName,
  String? accNumber,
  String? branchCode,
  String? ifsc,
  String? bankAddress,
  dynamic master,
  String? slug,
  String? about,
  String? note,
  String? commissionType,
  String? commission,
  String? file,
  String? seoTitle,
  String? seoDesc,
  String? deviceToken,
  String? deviceType,
  List<dynamic>? lpManager,
  List<dynamic>? deliveryBoy,
  String? doc1Type,
  String? doc1,
  String? doc2Type,
  String? doc2,
  String? doc3Type,
  String? doc3,
  num? codOrderCost,
  num? additionalCost1,
  num? additionalCost2,
  String? refferBy,
  num? firstTime,
  dynamic office,
  String? salary,
  String? fatherName,
  String? presentAddress,
  String? country,
  String? city2,
  String? state,
  String? zipcode,
  String? healthInsuranceNumber,
  String? aadhar,
  String? pan,
  dynamic dateOfJoin,
  dynamic dateOfReleiving,
  String? post,
  List<dynamic>? bagNo,
  dynamic role,
  String? pricePerKmWithoutOrder,
  String? id,
  String? createdDate,
  num? v,
}) => CargoPartner(  vendorPosition: vendorPosition ?? _vendorPosition,
  cargoPosition: cargoPosition ?? _cargoPosition,
  deliveryPartnerPosition: deliveryPartnerPosition ?? _deliveryPartnerPosition,
  subscription: subscription ?? _subscription,
  fullName: fullName ?? _fullName,
  email: email ?? _email,
  password: password ?? _password,
  mobile: mobile ?? _mobile,
  userType: userType ?? _userType,
  otp: otp ?? _otp,
  emailOtp: emailOtp ?? _emailOtp,
  updateDate: updateDate ?? _updateDate,
  profileImage: profileImage ?? _profileImage,
  active: active ?? _active,
  loginActive: loginActive ?? _loginActive,
  deleted: deleted ?? _deleted,
  address: address ?? _address,
  city: city ?? _city,
  cod: cod ?? _cod,
  customerSupportCity: customerSupportCity ?? _customerSupportCity,
  deliveryCity: deliveryCity ?? _deliveryCity,
  pricePerKg: pricePerKg ?? _pricePerKg,
  pricePerPack: pricePerPack ?? _pricePerPack,
  ratePerKm: ratePerKm ?? _ratePerKm,
  monthlyFixedCost: monthlyFixedCost ?? _monthlyFixedCost,
  communicationZipcode: communicationZipcode ?? _communicationZipcode,
  serviceZipcode: serviceZipcode ?? _serviceZipcode,
  bankName: bankName ?? _bankName,
  accHolderName: accHolderName ?? _accHolderName,
  accNumber: accNumber ?? _accNumber,
  branchCode: branchCode ?? _branchCode,
  ifsc: ifsc ?? _ifsc,
  bankAddress: bankAddress ?? _bankAddress,
  master: master ?? _master,
  slug: slug ?? _slug,
  about: about ?? _about,
  note: note ?? _note,
  commissionType: commissionType ?? _commissionType,
  commission: commission ?? _commission,
  file: file ?? _file,
  seoTitle: seoTitle ?? _seoTitle,
  seoDesc: seoDesc ?? _seoDesc,
  deviceToken: deviceToken ?? _deviceToken,
  deviceType: deviceType ?? _deviceType,
  lpManager: lpManager ?? _lpManager,
  deliveryBoy: deliveryBoy ?? _deliveryBoy,
  doc1Type: doc1Type ?? _doc1Type,
  doc1: doc1 ?? _doc1,
  doc2Type: doc2Type ?? _doc2Type,
  doc2: doc2 ?? _doc2,
  doc3Type: doc3Type ?? _doc3Type,
  doc3: doc3 ?? _doc3,
  codOrderCost: codOrderCost ?? _codOrderCost,
  additionalCost1: additionalCost1 ?? _additionalCost1,
  additionalCost2: additionalCost2 ?? _additionalCost2,
  refferBy: refferBy ?? _refferBy,
  firstTime: firstTime ?? _firstTime,
  office: office ?? _office,
  salary: salary ?? _salary,
  fatherName: fatherName ?? _fatherName,
  presentAddress: presentAddress ?? _presentAddress,
  country: country ?? _country,
  city2: city2 ?? _city2,
  state: state ?? _state,
  zipcode: zipcode ?? _zipcode,
  healthInsuranceNumber: healthInsuranceNumber ?? _healthInsuranceNumber,
  aadhar: aadhar ?? _aadhar,
  pan: pan ?? _pan,
  dateOfJoin: dateOfJoin ?? _dateOfJoin,
  dateOfReleiving: dateOfReleiving ?? _dateOfReleiving,
  post: post ?? _post,
  bagNo: bagNo ?? _bagNo,
  role: role ?? _role,
  pricePerKmWithoutOrder: pricePerKmWithoutOrder ?? _pricePerKmWithoutOrder,
  id: id ?? _id,
  createdDate: createdDate ?? _createdDate,
  v: v ?? _v,
);
  VendorPosition? get vendorPosition => _vendorPosition;
  CargoPosition? get cargoPosition => _cargoPosition;
  DeliveryPartnerPosition? get deliveryPartnerPosition => _deliveryPartnerPosition;
  Subscription? get subscription => _subscription;
  String? get fullName => _fullName;
  String? get email => _email;
  String? get password => _password;
  String? get mobile => _mobile;
  String? get userType => _userType;
  num? get otp => _otp;
  num? get emailOtp => _emailOtp;
  String? get updateDate => _updateDate;
  String? get profileImage => _profileImage;
  num? get active => _active;
  num? get loginActive => _loginActive;
  num? get deleted => _deleted;
  String? get address => _address;
  dynamic get city => _city;
  dynamic get cod => _cod;
  List<String>? get customerSupportCity => _customerSupportCity;
  List<dynamic>? get deliveryCity => _deliveryCity;
  String? get pricePerKg => _pricePerKg;
  String? get pricePerPack => _pricePerPack;
  String? get ratePerKm => _ratePerKm;
  String? get monthlyFixedCost => _monthlyFixedCost;
  String? get communicationZipcode => _communicationZipcode;
  String? get serviceZipcode => _serviceZipcode;
  String? get bankName => _bankName;
  String? get accHolderName => _accHolderName;
  String? get accNumber => _accNumber;
  String? get branchCode => _branchCode;
  String? get ifsc => _ifsc;
  String? get bankAddress => _bankAddress;
  dynamic get master => _master;
  String? get slug => _slug;
  String? get about => _about;
  String? get note => _note;
  String? get commissionType => _commissionType;
  String? get commission => _commission;
  String? get file => _file;
  String? get seoTitle => _seoTitle;
  String? get seoDesc => _seoDesc;
  String? get deviceToken => _deviceToken;
  String? get deviceType => _deviceType;
  List<dynamic>? get lpManager => _lpManager;
  List<dynamic>? get deliveryBoy => _deliveryBoy;
  String? get doc1Type => _doc1Type;
  String? get doc1 => _doc1;
  String? get doc2Type => _doc2Type;
  String? get doc2 => _doc2;
  String? get doc3Type => _doc3Type;
  String? get doc3 => _doc3;
  num? get codOrderCost => _codOrderCost;
  num? get additionalCost1 => _additionalCost1;
  num? get additionalCost2 => _additionalCost2;
  String? get refferBy => _refferBy;
  num? get firstTime => _firstTime;
  dynamic get office => _office;
  String? get salary => _salary;
  String? get fatherName => _fatherName;
  String? get presentAddress => _presentAddress;
  String? get country => _country;
  String? get city2 => _city2;
  String? get state => _state;
  String? get zipcode => _zipcode;
  String? get healthInsuranceNumber => _healthInsuranceNumber;
  String? get aadhar => _aadhar;
  String? get pan => _pan;
  dynamic get dateOfJoin => _dateOfJoin;
  dynamic get dateOfReleiving => _dateOfReleiving;
  String? get post => _post;
  List<dynamic>? get bagNo => _bagNo;
  dynamic get role => _role;
  String? get pricePerKmWithoutOrder => _pricePerKmWithoutOrder;
  String? get id => _id;
  String? get createdDate => _createdDate;
  num? get v => _v;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (_vendorPosition != null) {
      map['vendor_position'] = _vendorPosition?.toJson();
    }
    if (_cargoPosition != null) {
      map['cargo_position'] = _cargoPosition?.toJson();
    }
    if (_deliveryPartnerPosition != null) {
      map['delivery_partner_position'] = _deliveryPartnerPosition?.toJson();
    }
    if (_subscription != null) {
      map['subscription'] = _subscription?.toJson();
    }
    map['full_name'] = _fullName;
    map['email'] = _email;
    map['password'] = _password;
    map['mobile'] = _mobile;
    map['user_type'] = _userType;
    map['otp'] = _otp;
    map['email_otp'] = _emailOtp;
    map['update_date'] = _updateDate;
    map['profile_image'] = _profileImage;
    map['active'] = _active;
    map['login_active'] = _loginActive;
    map['deleted'] = _deleted;
    map['address'] = _address;
    map['city'] = _city;
    map['cod'] = _cod;
    map['customer_support_city'] = _customerSupportCity;
    if (_deliveryCity != null) {
      map['delivery_city'] = _deliveryCity?.map((v) => v.toJson()).toList();
    }
    map['price_per_kg'] = _pricePerKg;
    map['price_per_pack'] = _pricePerPack;
    map['rate_per_km'] = _ratePerKm;
    map['monthly_fixed_cost'] = _monthlyFixedCost;
    map['communication_zipcode'] = _communicationZipcode;
    map['service_zipcode'] = _serviceZipcode;
    map['bank_name'] = _bankName;
    map['acc_holder_name'] = _accHolderName;
    map['acc_number'] = _accNumber;
    map['branch_code'] = _branchCode;
    map['ifsc'] = _ifsc;
    map['bank_address'] = _bankAddress;
    map['master'] = _master;
    map['slug'] = _slug;
    map['about'] = _about;
    map['note'] = _note;
    map['commission_type'] = _commissionType;
    map['commission'] = _commission;
    map['file'] = _file;
    map['seo_title'] = _seoTitle;
    map['seo_desc'] = _seoDesc;
    map['device_token'] = _deviceToken;
    map['device_type'] = _deviceType;
    if (_lpManager != null) {
      map['lp_manager'] = _lpManager?.map((v) => v.toJson()).toList();
    }
    if (_deliveryBoy != null) {
      map['delivery_boy'] = _deliveryBoy?.map((v) => v.toJson()).toList();
    }
    map['doc1_type'] = _doc1Type;
    map['doc1'] = _doc1;
    map['doc2_type'] = _doc2Type;
    map['doc2'] = _doc2;
    map['doc3_type'] = _doc3Type;
    map['doc3'] = _doc3;
    map['cod_order_cost'] = _codOrderCost;
    map['additional_cost1'] = _additionalCost1;
    map['additional_cost2'] = _additionalCost2;
    map['reffer_by'] = _refferBy;
    map['first_time'] = _firstTime;
    map['office'] = _office;
    map['salary'] = _salary;
    map['father_name'] = _fatherName;
    map['present_address'] = _presentAddress;
    map['country'] = _country;
    map['city2'] = _city2;
    map['state'] = _state;
    map['zipcode'] = _zipcode;
    map['health_insurance_number'] = _healthInsuranceNumber;
    map['aadhar'] = _aadhar;
    map['pan'] = _pan;
    map['date_of_join'] = _dateOfJoin;
    map['date_of_releiving'] = _dateOfReleiving;
    map['post'] = _post;
    if (_bagNo != null) {
      map['bag_no'] = _bagNo?.map((v) => v.toJson()).toList();
    }
    map['role'] = _role;
    map['price_per_km_without_order'] = _pricePerKmWithoutOrder;
    map['_id'] = _id;
    map['created_date'] = _createdDate;
    map['__v'] = _v;
    return map;
  }

}

Vendor vendorFromJson(String str) => Vendor.fromJson(json.decode(str));
String vendorToJson(Vendor data) => json.encode(data.toJson());
class Vendor {
  Vendor({
      VendorPosition? vendorPosition,
      CargoPosition? cargoPosition,
      DeliveryPartnerPosition? deliveryPartnerPosition,
      Subscription? subscription,
      String? fullName,
      String? email,
      String? password,
      String? mobile,
      String? userType,
      num? otp,
      num? emailOtp,
      String? updateDate,
      dynamic profileImage,
      num? active,
      num? loginActive,
      num? deleted,
      String? address,
      String? city,
      num? cod,
      List<dynamic>? customerSupportCity,
      List<String>? deliveryCity,
      String? pricePerKg,
      String? pricePerPack,
      String? ratePerKm,
      String? monthlyFixedCost,
      String? communicationZipcode,
      String? serviceZipcode,
      dynamic bankName,
      dynamic accHolderName,
      dynamic accNumber,
      dynamic branchCode,
      dynamic ifsc,
      dynamic bankAddress,
      dynamic master,
      String? slug,
      String? about,
      String? note,
      String? commissionType,
      String? commission,
      String? file,
      String? seoTitle,
      String? seoDesc,
      String? deviceToken,
      String? deviceType,
      List<dynamic>? lpManager,
      List<dynamic>? deliveryBoy,
      String? doc1Type,
      String? doc1,
      String? doc2Type,
      String? doc2,
      String? doc3Type,
      String? doc3,
      num? codOrderCost,
      num? additionalCost1,
      num? additionalCost2,
      String? refferBy,
      num? firstTime,
      dynamic office,
      String? salary,
      String? fatherName,
      String? presentAddress,
      String? country,
      String? city2,
      String? state,
      String? zipcode,
      String? healthInsuranceNumber,
      String? aadhar,
      String? pan,
      dynamic dateOfJoin,
      dynamic dateOfReleiving,
      String? post,
      List<dynamic>? bagNo,
      dynamic role,
      String? pricePerKmWithoutOrder,
      String? id,
      String? createdDate,
      num? v,}){
    _vendorPosition = vendorPosition;
    _cargoPosition = cargoPosition;
    _deliveryPartnerPosition = deliveryPartnerPosition;
    _subscription = subscription;
    _fullName = fullName;
    _email = email;
    _password = password;
    _mobile = mobile;
    _userType = userType;
    _otp = otp;
    _emailOtp = emailOtp;
    _updateDate = updateDate;
    _profileImage = profileImage;
    _active = active;
    _loginActive = loginActive;
    _deleted = deleted;
    _address = address;
    _city = city;
    _cod = cod;
    _customerSupportCity = customerSupportCity;
    _deliveryCity = deliveryCity;
    _pricePerKg = pricePerKg;
    _pricePerPack = pricePerPack;
    _ratePerKm = ratePerKm;
    _monthlyFixedCost = monthlyFixedCost;
    _communicationZipcode = communicationZipcode;
    _serviceZipcode = serviceZipcode;
    _bankName = bankName;
    _accHolderName = accHolderName;
    _accNumber = accNumber;
    _branchCode = branchCode;
    _ifsc = ifsc;
    _bankAddress = bankAddress;
    _master = master;
    _slug = slug;
    _about = about;
    _note = note;
    _commissionType = commissionType;
    _commission = commission;
    _file = file;
    _seoTitle = seoTitle;
    _seoDesc = seoDesc;
    _deviceToken = deviceToken;
    _deviceType = deviceType;
    _lpManager = lpManager;
    _deliveryBoy = deliveryBoy;
    _doc1Type = doc1Type;
    _doc1 = doc1;
    _doc2Type = doc2Type;
    _doc2 = doc2;
    _doc3Type = doc3Type;
    _doc3 = doc3;
    _codOrderCost = codOrderCost;
    _additionalCost1 = additionalCost1;
    _additionalCost2 = additionalCost2;
    _refferBy = refferBy;
    _firstTime = firstTime;
    _office = office;
    _salary = salary;
    _fatherName = fatherName;
    _presentAddress = presentAddress;
    _country = country;
    _city2 = city2;
    _state = state;
    _zipcode = zipcode;
    _healthInsuranceNumber = healthInsuranceNumber;
    _aadhar = aadhar;
    _pan = pan;
    _dateOfJoin = dateOfJoin;
    _dateOfReleiving = dateOfReleiving;
    _post = post;
    _bagNo = bagNo;
    _role = role;
    _pricePerKmWithoutOrder = pricePerKmWithoutOrder;
    _id = id;
    _createdDate = createdDate;
    _v = v;
}

  Vendor.fromJson(dynamic json) {
    _vendorPosition = json['vendor_position'] != null ? VendorPosition.fromJson(json['vendor_position']) : null;
    _cargoPosition = json['cargo_position'] != null ? CargoPosition.fromJson(json['cargo_position']) : null;
    _deliveryPartnerPosition = json['delivery_partner_position'] != null ? DeliveryPartnerPosition.fromJson(json['delivery_partner_position']) : null;
    _subscription = json['subscription'] != null ? Subscription.fromJson(json['subscription']) : null;
    _fullName = json['full_name'];
    _email = json['email'];
    _password = json['password'];
    _mobile = json['mobile'];
    _userType = json['user_type'];
    _otp = json['otp'];
    _emailOtp = json['email_otp'];
    _updateDate = json['update_date'];
    _profileImage = json['profile_image'];
    _active = json['active'];
    _loginActive = json['login_active'];
    _deleted = json['deleted'];
    _address = json['address'];
    _city = json['city'];
    _cod = json['cod'];
    if (json['customer_support_city'] != null) {
      _customerSupportCity = [];
      json['customer_support_city'].forEach((v) {
        _customerSupportCity?.add(v);
      });
    }
    _deliveryCity = json['delivery_city'] != null ? json['delivery_city'].cast<String>() : [];
    _pricePerKg = json['price_per_kg'];
    _pricePerPack = json['price_per_pack'];
    _ratePerKm = json['rate_per_km'];
    _monthlyFixedCost = json['monthly_fixed_cost'];
    _communicationZipcode = json['communication_zipcode'];
    _serviceZipcode = json['service_zipcode'];
    _bankName = json['bank_name'];
    _accHolderName = json['acc_holder_name'];
    _accNumber = json['acc_number'];
    _branchCode = json['branch_code'];
    _ifsc = json['ifsc'];
    _bankAddress = json['bank_address'];
    _master = json['master'];
    _slug = json['slug'];
    _about = json['about'];
    _note = json['note'];
    _commissionType = json['commission_type'];
    _commission = json['commission'];
    _file = json['file'];
    _seoTitle = json['seo_title'];
    _seoDesc = json['seo_desc'];
    _deviceToken = json['device_token'];
    _deviceType = json['device_type'];
    if (json['lp_manager'] != null) {
      _lpManager = [];
      json['lp_manager'].forEach((v) {
        _lpManager?.add(v);
      });
    }
    if (json['delivery_boy'] != null) {
      _deliveryBoy = [];
      json['delivery_boy'].forEach((v) {
        _deliveryBoy?.add(v);
      });
    }
    _doc1Type = json['doc1_type'];
    _doc1 = json['doc1'];
    _doc2Type = json['doc2_type'];
    _doc2 = json['doc2'];
    _doc3Type = json['doc3_type'];
    _doc3 = json['doc3'];
    _codOrderCost = json['cod_order_cost'];
    _additionalCost1 = json['additional_cost1'];
    _additionalCost2 = json['additional_cost2'];
    _refferBy = json['reffer_by'];
    _firstTime = json['first_time'];
    _office = json['office'];
    _salary = json['salary'];
    _fatherName = json['father_name'];
    _presentAddress = json['present_address'];
    _country = json['country'];
    _city2 = json['city2'];
    _state = json['state'];
    _zipcode = json['zipcode'];
    _healthInsuranceNumber = json['health_insurance_number'];
    _aadhar = json['aadhar'];
    _pan = json['pan'];
    _dateOfJoin = json['date_of_join'];
    _dateOfReleiving = json['date_of_releiving'];
    _post = json['post'];
    if (json['bag_no'] != null) {
      _bagNo = [];
      json['bag_no'].forEach((v) {
        _bagNo?.add(v);
      });
    }
    _role = json['role'];
    _pricePerKmWithoutOrder = json['price_per_km_without_order'];
    _id = json['_id'];
    _createdDate = json['created_date'];
    _v = json['__v'];
  }
  VendorPosition? _vendorPosition;
  CargoPosition? _cargoPosition;
  DeliveryPartnerPosition? _deliveryPartnerPosition;
  Subscription? _subscription;
  String? _fullName;
  String? _email;
  String? _password;
  String? _mobile;
  String? _userType;
  num? _otp;
  num? _emailOtp;
  String? _updateDate;
  dynamic _profileImage;
  num? _active;
  num? _loginActive;
  num? _deleted;
  String? _address;
  String? _city;
  num? _cod;
  List<dynamic>? _customerSupportCity;
  List<String>? _deliveryCity;
  String? _pricePerKg;
  String? _pricePerPack;
  String? _ratePerKm;
  String? _monthlyFixedCost;
  String? _communicationZipcode;
  String? _serviceZipcode;
  dynamic _bankName;
  dynamic _accHolderName;
  dynamic _accNumber;
  dynamic _branchCode;
  dynamic _ifsc;
  dynamic _bankAddress;
  dynamic _master;
  String? _slug;
  String? _about;
  String? _note;
  String? _commissionType;
  String? _commission;
  String? _file;
  String? _seoTitle;
  String? _seoDesc;
  String? _deviceToken;
  String? _deviceType;
  List<dynamic>? _lpManager;
  List<dynamic>? _deliveryBoy;
  String? _doc1Type;
  String? _doc1;
  String? _doc2Type;
  String? _doc2;
  String? _doc3Type;
  String? _doc3;
  num? _codOrderCost;
  num? _additionalCost1;
  num? _additionalCost2;
  String? _refferBy;
  num? _firstTime;
  dynamic _office;
  String? _salary;
  String? _fatherName;
  String? _presentAddress;
  String? _country;
  String? _city2;
  String? _state;
  String? _zipcode;
  String? _healthInsuranceNumber;
  String? _aadhar;
  String? _pan;
  dynamic _dateOfJoin;
  dynamic _dateOfReleiving;
  String? _post;
  List<dynamic>? _bagNo;
  dynamic _role;
  String? _pricePerKmWithoutOrder;
  String? _id;
  String? _createdDate;
  num? _v;
Vendor copyWith({  VendorPosition? vendorPosition,
  CargoPosition? cargoPosition,
  DeliveryPartnerPosition? deliveryPartnerPosition,
  Subscription? subscription,
  String? fullName,
  String? email,
  String? password,
  String? mobile,
  String? userType,
  num? otp,
  num? emailOtp,
  String? updateDate,
  dynamic profileImage,
  num? active,
  num? loginActive,
  num? deleted,
  String? address,
  String? city,
  num? cod,
  List<dynamic>? customerSupportCity,
  List<String>? deliveryCity,
  String? pricePerKg,
  String? pricePerPack,
  String? ratePerKm,
  String? monthlyFixedCost,
  String? communicationZipcode,
  String? serviceZipcode,
  dynamic bankName,
  dynamic accHolderName,
  dynamic accNumber,
  dynamic branchCode,
  dynamic ifsc,
  dynamic bankAddress,
  dynamic master,
  String? slug,
  String? about,
  String? note,
  String? commissionType,
  String? commission,
  String? file,
  String? seoTitle,
  String? seoDesc,
  String? deviceToken,
  String? deviceType,
  List<dynamic>? lpManager,
  List<dynamic>? deliveryBoy,
  String? doc1Type,
  String? doc1,
  String? doc2Type,
  String? doc2,
  String? doc3Type,
  String? doc3,
  num? codOrderCost,
  num? additionalCost1,
  num? additionalCost2,
  String? refferBy,
  num? firstTime,
  dynamic office,
  String? salary,
  String? fatherName,
  String? presentAddress,
  String? country,
  String? city2,
  String? state,
  String? zipcode,
  String? healthInsuranceNumber,
  String? aadhar,
  String? pan,
  dynamic dateOfJoin,
  dynamic dateOfReleiving,
  String? post,
  List<dynamic>? bagNo,
  dynamic role,
  String? pricePerKmWithoutOrder,
  String? id,
  String? createdDate,
  num? v,
}) => Vendor(  vendorPosition: vendorPosition ?? _vendorPosition,
  cargoPosition: cargoPosition ?? _cargoPosition,
  deliveryPartnerPosition: deliveryPartnerPosition ?? _deliveryPartnerPosition,
  subscription: subscription ?? _subscription,
  fullName: fullName ?? _fullName,
  email: email ?? _email,
  password: password ?? _password,
  mobile: mobile ?? _mobile,
  userType: userType ?? _userType,
  otp: otp ?? _otp,
  emailOtp: emailOtp ?? _emailOtp,
  updateDate: updateDate ?? _updateDate,
  profileImage: profileImage ?? _profileImage,
  active: active ?? _active,
  loginActive: loginActive ?? _loginActive,
  deleted: deleted ?? _deleted,
  address: address ?? _address,
  city: city ?? _city,
  cod: cod ?? _cod,
  customerSupportCity: customerSupportCity ?? _customerSupportCity,
  deliveryCity: deliveryCity ?? _deliveryCity,
  pricePerKg: pricePerKg ?? _pricePerKg,
  pricePerPack: pricePerPack ?? _pricePerPack,
  ratePerKm: ratePerKm ?? _ratePerKm,
  monthlyFixedCost: monthlyFixedCost ?? _monthlyFixedCost,
  communicationZipcode: communicationZipcode ?? _communicationZipcode,
  serviceZipcode: serviceZipcode ?? _serviceZipcode,
  bankName: bankName ?? _bankName,
  accHolderName: accHolderName ?? _accHolderName,
  accNumber: accNumber ?? _accNumber,
  branchCode: branchCode ?? _branchCode,
  ifsc: ifsc ?? _ifsc,
  bankAddress: bankAddress ?? _bankAddress,
  master: master ?? _master,
  slug: slug ?? _slug,
  about: about ?? _about,
  note: note ?? _note,
  commissionType: commissionType ?? _commissionType,
  commission: commission ?? _commission,
  file: file ?? _file,
  seoTitle: seoTitle ?? _seoTitle,
  seoDesc: seoDesc ?? _seoDesc,
  deviceToken: deviceToken ?? _deviceToken,
  deviceType: deviceType ?? _deviceType,
  lpManager: lpManager ?? _lpManager,
  deliveryBoy: deliveryBoy ?? _deliveryBoy,
  doc1Type: doc1Type ?? _doc1Type,
  doc1: doc1 ?? _doc1,
  doc2Type: doc2Type ?? _doc2Type,
  doc2: doc2 ?? _doc2,
  doc3Type: doc3Type ?? _doc3Type,
  doc3: doc3 ?? _doc3,
  codOrderCost: codOrderCost ?? _codOrderCost,
  additionalCost1: additionalCost1 ?? _additionalCost1,
  additionalCost2: additionalCost2 ?? _additionalCost2,
  refferBy: refferBy ?? _refferBy,
  firstTime: firstTime ?? _firstTime,
  office: office ?? _office,
  salary: salary ?? _salary,
  fatherName: fatherName ?? _fatherName,
  presentAddress: presentAddress ?? _presentAddress,
  country: country ?? _country,
  city2: city2 ?? _city2,
  state: state ?? _state,
  zipcode: zipcode ?? _zipcode,
  healthInsuranceNumber: healthInsuranceNumber ?? _healthInsuranceNumber,
  aadhar: aadhar ?? _aadhar,
  pan: pan ?? _pan,
  dateOfJoin: dateOfJoin ?? _dateOfJoin,
  dateOfReleiving: dateOfReleiving ?? _dateOfReleiving,
  post: post ?? _post,
  bagNo: bagNo ?? _bagNo,
  role: role ?? _role,
  pricePerKmWithoutOrder: pricePerKmWithoutOrder ?? _pricePerKmWithoutOrder,
  id: id ?? _id,
  createdDate: createdDate ?? _createdDate,
  v: v ?? _v,
);
  VendorPosition? get vendorPosition => _vendorPosition;
  CargoPosition? get cargoPosition => _cargoPosition;
  DeliveryPartnerPosition? get deliveryPartnerPosition => _deliveryPartnerPosition;
  Subscription? get subscription => _subscription;
  String? get fullName => _fullName;
  String? get email => _email;
  String? get password => _password;
  String? get mobile => _mobile;
  String? get userType => _userType;
  num? get otp => _otp;
  num? get emailOtp => _emailOtp;
  String? get updateDate => _updateDate;
  dynamic get profileImage => _profileImage;
  num? get active => _active;
  num? get loginActive => _loginActive;
  num? get deleted => _deleted;
  String? get address => _address;
  String? get city => _city;
  num? get cod => _cod;
  List<dynamic>? get customerSupportCity => _customerSupportCity;
  List<String>? get deliveryCity => _deliveryCity;
  String? get pricePerKg => _pricePerKg;
  String? get pricePerPack => _pricePerPack;
  String? get ratePerKm => _ratePerKm;
  String? get monthlyFixedCost => _monthlyFixedCost;
  String? get communicationZipcode => _communicationZipcode;
  String? get serviceZipcode => _serviceZipcode;
  dynamic get bankName => _bankName;
  dynamic get accHolderName => _accHolderName;
  dynamic get accNumber => _accNumber;
  dynamic get branchCode => _branchCode;
  dynamic get ifsc => _ifsc;
  dynamic get bankAddress => _bankAddress;
  dynamic get master => _master;
  String? get slug => _slug;
  String? get about => _about;
  String? get note => _note;
  String? get commissionType => _commissionType;
  String? get commission => _commission;
  String? get file => _file;
  String? get seoTitle => _seoTitle;
  String? get seoDesc => _seoDesc;
  String? get deviceToken => _deviceToken;
  String? get deviceType => _deviceType;
  List<dynamic>? get lpManager => _lpManager;
  List<dynamic>? get deliveryBoy => _deliveryBoy;
  String? get doc1Type => _doc1Type;
  String? get doc1 => _doc1;
  String? get doc2Type => _doc2Type;
  String? get doc2 => _doc2;
  String? get doc3Type => _doc3Type;
  String? get doc3 => _doc3;
  num? get codOrderCost => _codOrderCost;
  num? get additionalCost1 => _additionalCost1;
  num? get additionalCost2 => _additionalCost2;
  String? get refferBy => _refferBy;
  num? get firstTime => _firstTime;
  dynamic get office => _office;
  String? get salary => _salary;
  String? get fatherName => _fatherName;
  String? get presentAddress => _presentAddress;
  String? get country => _country;
  String? get city2 => _city2;
  String? get state => _state;
  String? get zipcode => _zipcode;
  String? get healthInsuranceNumber => _healthInsuranceNumber;
  String? get aadhar => _aadhar;
  String? get pan => _pan;
  dynamic get dateOfJoin => _dateOfJoin;
  dynamic get dateOfReleiving => _dateOfReleiving;
  String? get post => _post;
  List<dynamic>? get bagNo => _bagNo;
  dynamic get role => _role;
  String? get pricePerKmWithoutOrder => _pricePerKmWithoutOrder;
  String? get id => _id;
  String? get createdDate => _createdDate;
  num? get v => _v;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (_vendorPosition != null) {
      map['vendor_position'] = _vendorPosition?.toJson();
    }
    if (_cargoPosition != null) {
      map['cargo_position'] = _cargoPosition?.toJson();
    }
    if (_deliveryPartnerPosition != null) {
      map['delivery_partner_position'] = _deliveryPartnerPosition?.toJson();
    }
    if (_subscription != null) {
      map['subscription'] = _subscription?.toJson();
    }
    map['full_name'] = _fullName;
    map['email'] = _email;
    map['password'] = _password;
    map['mobile'] = _mobile;
    map['user_type'] = _userType;
    map['otp'] = _otp;
    map['email_otp'] = _emailOtp;
    map['update_date'] = _updateDate;
    map['profile_image'] = _profileImage;
    map['active'] = _active;
    map['login_active'] = _loginActive;
    map['deleted'] = _deleted;
    map['address'] = _address;
    map['city'] = _city;
    map['cod'] = _cod;
    if (_customerSupportCity != null) {
      map['customer_support_city'] = _customerSupportCity?.map((v) => v.toJson()).toList();
    }
    map['delivery_city'] = _deliveryCity;
    map['price_per_kg'] = _pricePerKg;
    map['price_per_pack'] = _pricePerPack;
    map['rate_per_km'] = _ratePerKm;
    map['monthly_fixed_cost'] = _monthlyFixedCost;
    map['communication_zipcode'] = _communicationZipcode;
    map['service_zipcode'] = _serviceZipcode;
    map['bank_name'] = _bankName;
    map['acc_holder_name'] = _accHolderName;
    map['acc_number'] = _accNumber;
    map['branch_code'] = _branchCode;
    map['ifsc'] = _ifsc;
    map['bank_address'] = _bankAddress;
    map['master'] = _master;
    map['slug'] = _slug;
    map['about'] = _about;
    map['note'] = _note;
    map['commission_type'] = _commissionType;
    map['commission'] = _commission;
    map['file'] = _file;
    map['seo_title'] = _seoTitle;
    map['seo_desc'] = _seoDesc;
    map['device_token'] = _deviceToken;
    map['device_type'] = _deviceType;
    if (_lpManager != null) {
      map['lp_manager'] = _lpManager?.map((v) => v.toJson()).toList();
    }
    if (_deliveryBoy != null) {
      map['delivery_boy'] = _deliveryBoy?.map((v) => v.toJson()).toList();
    }
    map['doc1_type'] = _doc1Type;
    map['doc1'] = _doc1;
    map['doc2_type'] = _doc2Type;
    map['doc2'] = _doc2;
    map['doc3_type'] = _doc3Type;
    map['doc3'] = _doc3;
    map['cod_order_cost'] = _codOrderCost;
    map['additional_cost1'] = _additionalCost1;
    map['additional_cost2'] = _additionalCost2;
    map['reffer_by'] = _refferBy;
    map['first_time'] = _firstTime;
    map['office'] = _office;
    map['salary'] = _salary;
    map['father_name'] = _fatherName;
    map['present_address'] = _presentAddress;
    map['country'] = _country;
    map['city2'] = _city2;
    map['state'] = _state;
    map['zipcode'] = _zipcode;
    map['health_insurance_number'] = _healthInsuranceNumber;
    map['aadhar'] = _aadhar;
    map['pan'] = _pan;
    map['date_of_join'] = _dateOfJoin;
    map['date_of_releiving'] = _dateOfReleiving;
    map['post'] = _post;
    if (_bagNo != null) {
      map['bag_no'] = _bagNo?.map((v) => v.toJson()).toList();
    }
    map['role'] = _role;
    map['price_per_km_without_order'] = _pricePerKmWithoutOrder;
    map['_id'] = _id;
    map['created_date'] = _createdDate;
    map['__v'] = _v;
    return map;
  }

}


