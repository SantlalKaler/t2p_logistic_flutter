import 'dart:convert';
AllDeliveryStatusResponse allDeliveryStatusResponseFromJson(String str) => AllDeliveryStatusResponse.fromJson(json.decode(str));
String allDeliveryStatusResponseToJson(AllDeliveryStatusResponse data) => json.encode(data.toJson());
class AllDeliveryStatusResponse {
  AllDeliveryStatusResponse({
      String? status, 
      String? message, 
      Result? result,}){
    _status = status;
    _message = message;
    _result = result;
}

  AllDeliveryStatusResponse.fromJson(dynamic json) {
    _status = json['status'];
    _message = json['message'];
    _result = json['result'] != null ? Result.fromJson(json['result']) : null;
  }
  String? _status;
  String? _message;
  Result? _result;
AllDeliveryStatusResponse copyWith({  String? status,
  String? message,
  Result? result,
}) => AllDeliveryStatusResponse(  status: status ?? _status,
  message: message ?? _message,
  result: result ?? _result,
);
  String? get status => _status;
  String? get message => _message;
  Result? get result => _result;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['status'] = _status;
    map['message'] = _message;
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
      String? deleted, 
      String? pendingPayment, 
      String? waitingVendorApproval, 
      String? vendorApproved, 
      String? onHold, 
      String? readyPickup, 
      String? pickupBoyAssigned, 
      String? pickupBoyStarted, 
      String? deliveredToCargoPartner, 
      String? cargoOffLoaded, 
      String? cargoDeliveryStarted, 
      String? receivedDestinationAirport, 
      String? deliveredToDeliveryPartner, 
      String? deliveryBoyAssigned, 
      String? deliveryBoyStarted, 
      String? delivered, 
      String? cancel, 
      String? failed, 
      String? refunded, 
      String? rejectedCustomer, 
      String? declinedVendor, 
      String? complimentary,}){
    _deleted = deleted;
    _pendingPayment = pendingPayment;
    _waitingVendorApproval = waitingVendorApproval;
    _vendorApproved = vendorApproved;
    _onHold = onHold;
    _readyPickup = readyPickup;
    _pickupBoyAssigned = pickupBoyAssigned;
    _pickupBoyStarted = pickupBoyStarted;
    _deliveredToCargoPartner = deliveredToCargoPartner;
    _cargoOffLoaded = cargoOffLoaded;
    _cargoDeliveryStarted = cargoDeliveryStarted;
    _receivedDestinationAirport = receivedDestinationAirport;
    _deliveredToDeliveryPartner = deliveredToDeliveryPartner;
    _deliveryBoyAssigned = deliveryBoyAssigned;
    _deliveryBoyStarted = deliveryBoyStarted;
    _delivered = delivered;
    _cancel = cancel;
    _failed = failed;
    _refunded = refunded;
    _rejectedCustomer = rejectedCustomer;
    _declinedVendor = declinedVendor;
    _complimentary = complimentary;
}

  Result.fromJson(dynamic json) {
    _deleted = json['deleted'];
    _pendingPayment = json['pending_payment'];
    _waitingVendorApproval = json['waiting_vendor_approval'];
    _vendorApproved = json['vendor_approved'];
    _onHold = json['on_hold'];
    _readyPickup = json['ready_pickup'];
    _pickupBoyAssigned = json['pickup_boy_assigned'];
    _pickupBoyStarted = json['pickup_boy_started'];
    _deliveredToCargoPartner = json['delivered_to_cargo_partner'];
    _cargoOffLoaded = json['cargo_off_loaded'];
    _cargoDeliveryStarted = json['cargo_delivery_started'];
    _receivedDestinationAirport = json['received_destination_airport'];
    _deliveredToDeliveryPartner = json['delivered_to_delivery_partner'];
    _deliveryBoyAssigned = json['delivery_boy_assigned'];
    _deliveryBoyStarted = json['delivery_boy_started'];
    _delivered = json['delivered'];
    _cancel = json['cancel'];
    _failed = json['failed'];
    _refunded = json['refunded'];
    _rejectedCustomer = json['rejected_customer'];
    _declinedVendor = json['declined_vendor'];
    _complimentary = json['complimentary'];
  }
  String? _deleted;
  String? _pendingPayment;
  String? _waitingVendorApproval;
  String? _vendorApproved;
  String? _onHold;
  String? _readyPickup;
  String? _pickupBoyAssigned;
  String? _pickupBoyStarted;
  String? _deliveredToCargoPartner;
  String? _cargoOffLoaded;
  String? _cargoDeliveryStarted;
  String? _receivedDestinationAirport;
  String? _deliveredToDeliveryPartner;
  String? _deliveryBoyAssigned;
  String? _deliveryBoyStarted;
  String? _delivered;
  String? _cancel;
  String? _failed;
  String? _refunded;
  String? _rejectedCustomer;
  String? _declinedVendor;
  String? _complimentary;
Result copyWith({  String? deleted,
  String? pendingPayment,
  String? waitingVendorApproval,
  String? vendorApproved,
  String? onHold,
  String? readyPickup,
  String? pickupBoyAssigned,
  String? pickupBoyStarted,
  String? deliveredToCargoPartner,
  String? cargoOffLoaded,
  String? cargoDeliveryStarted,
  String? receivedDestinationAirport,
  String? deliveredToDeliveryPartner,
  String? deliveryBoyAssigned,
  String? deliveryBoyStarted,
  String? delivered,
  String? cancel,
  String? failed,
  String? refunded,
  String? rejectedCustomer,
  String? declinedVendor,
  String? complimentary,
}) => Result(  deleted: deleted ?? _deleted,
  pendingPayment: pendingPayment ?? _pendingPayment,
  waitingVendorApproval: waitingVendorApproval ?? _waitingVendorApproval,
  vendorApproved: vendorApproved ?? _vendorApproved,
  onHold: onHold ?? _onHold,
  readyPickup: readyPickup ?? _readyPickup,
  pickupBoyAssigned: pickupBoyAssigned ?? _pickupBoyAssigned,
  pickupBoyStarted: pickupBoyStarted ?? _pickupBoyStarted,
  deliveredToCargoPartner: deliveredToCargoPartner ?? _deliveredToCargoPartner,
  cargoOffLoaded: cargoOffLoaded ?? _cargoOffLoaded,
  cargoDeliveryStarted: cargoDeliveryStarted ?? _cargoDeliveryStarted,
  receivedDestinationAirport: receivedDestinationAirport ?? _receivedDestinationAirport,
  deliveredToDeliveryPartner: deliveredToDeliveryPartner ?? _deliveredToDeliveryPartner,
  deliveryBoyAssigned: deliveryBoyAssigned ?? _deliveryBoyAssigned,
  deliveryBoyStarted: deliveryBoyStarted ?? _deliveryBoyStarted,
  delivered: delivered ?? _delivered,
  cancel: cancel ?? _cancel,
  failed: failed ?? _failed,
  refunded: refunded ?? _refunded,
  rejectedCustomer: rejectedCustomer ?? _rejectedCustomer,
  declinedVendor: declinedVendor ?? _declinedVendor,
  complimentary: complimentary ?? _complimentary,
);
  String? get deleted => _deleted;
  String? get pendingPayment => _pendingPayment;
  String? get waitingVendorApproval => _waitingVendorApproval;
  String? get vendorApproved => _vendorApproved;
  String? get onHold => _onHold;
  String? get readyPickup => _readyPickup;
  String? get pickupBoyAssigned => _pickupBoyAssigned;
  String? get pickupBoyStarted => _pickupBoyStarted;
  String? get deliveredToCargoPartner => _deliveredToCargoPartner;
  String? get cargoOffLoaded => _cargoOffLoaded;
  String? get cargoDeliveryStarted => _cargoDeliveryStarted;
  String? get receivedDestinationAirport => _receivedDestinationAirport;
  String? get deliveredToDeliveryPartner => _deliveredToDeliveryPartner;
  String? get deliveryBoyAssigned => _deliveryBoyAssigned;
  String? get deliveryBoyStarted => _deliveryBoyStarted;
  String? get delivered => _delivered;
  String? get cancel => _cancel;
  String? get failed => _failed;
  String? get refunded => _refunded;
  String? get rejectedCustomer => _rejectedCustomer;
  String? get declinedVendor => _declinedVendor;
  String? get complimentary => _complimentary;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['deleted'] = _deleted;
    map['pending_payment'] = _pendingPayment;
    map['waiting_vendor_approval'] = _waitingVendorApproval;
    map['vendor_approved'] = _vendorApproved;
    map['on_hold'] = _onHold;
    map['ready_pickup'] = _readyPickup;
    map['pickup_boy_assigned'] = _pickupBoyAssigned;
    map['pickup_boy_started'] = _pickupBoyStarted;
    map['delivered_to_cargo_partner'] = _deliveredToCargoPartner;
    map['cargo_off_loaded'] = _cargoOffLoaded;
    map['cargo_delivery_started'] = _cargoDeliveryStarted;
    map['received_destination_airport'] = _receivedDestinationAirport;
    map['delivered_to_delivery_partner'] = _deliveredToDeliveryPartner;
    map['delivery_boy_assigned'] = _deliveryBoyAssigned;
    map['delivery_boy_started'] = _deliveryBoyStarted;
    map['delivered'] = _delivered;
    map['cancel'] = _cancel;
    map['failed'] = _failed;
    map['refunded'] = _refunded;
    map['rejected_customer'] = _rejectedCustomer;
    map['declined_vendor'] = _declinedVendor;
    map['complimentary'] = _complimentary;
    return map;
  }

}