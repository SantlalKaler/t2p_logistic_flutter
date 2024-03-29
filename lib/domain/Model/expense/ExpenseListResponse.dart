import 'dart:convert';

import 'ExpenseCategoryListResponse.dart';
ExpenseListResponse expenseListResponseFromJson(String str) => ExpenseListResponse.fromJson(json.decode(str));
String expenseListResponseToJson(ExpenseListResponse data) => json.encode(data.toJson());
class ExpenseListResponse {
  ExpenseListResponse({
      String? status, 
      List<Expense>? expense,
      num? totalCount,}){
    _status = status;
    _expense = expense;
    _totalCount = totalCount;
}

  ExpenseListResponse.fromJson(dynamic json) {
    _status = json['status'];
    if (json['result'] != null) {
      _expense = [];
      json['result'].forEach((v) {
        _expense?.add(Expense.fromJson(v));
      });
    }
    _totalCount = json['totalCount'];
  }
  String? _status;
  List<Expense>? _expense;
  num? _totalCount;
ExpenseListResponse copyWith({  String? status,
  List<Expense>? result,
  num? totalCount,
}) => ExpenseListResponse(  status: status ?? _status,
  expense: result ?? _expense,
  totalCount: totalCount ?? _totalCount,
);
  String? get status => _status;
  List<Expense>? get expense => _expense;
  num? get totalCount => _totalCount;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['status'] = _status;
    if (_expense != null) {
      map['result'] = _expense?.map((v) => v.toJson()).toList();
    }
    map['totalCount'] = _totalCount;
    return map;
  }

}

Expense expenseFromJson(String str) => Expense.fromJson(json.decode(str));
String expenseToJson(Expense data) => json.encode(data.toJson());
class Expense {
  Expense({
      City? city, 
      CatSubCatCommon? category,
      CatSubCatCommon? subCategory,
      num? number, 
      String? name, 
      String? amount, 
      String? dateOfPayment, 
      String? comment, 
      num? active, 
      num? deleted, 
      String? updateDate, 
      AddedBy? addedBy, 
      dynamic office, 
      List<dynamic>? file, 
      String? officeType, 
      dynamic actionBy, 
      dynamic reason, 
      num? expenseType, 
      String? platform, 
      String? id, 
      String? createdDate, 
      num? v,}){
    _city = city;
    _category = category;
    _subCategory = subCategory;
    _number = number;
    _name = name;
    _amount = amount;
    _dateOfPayment = dateOfPayment;
    _comment = comment;
    _active = active;
    _deleted = deleted;
    _updateDate = updateDate;
    _addedBy = addedBy;
    _office = office;
    _file = file;
    _officeType = officeType;
    _actionBy = actionBy;
    _reason = reason;
    _expenseType = expenseType;
    _platform = platform;
    _id = id;
    _createdDate = createdDate;
    _v = v;
}

  Expense.fromJson(dynamic json) {
    _city = json['city'] != null ? City.fromJson(json['city']) : null;
    _category = json['category'] != null ? CatSubCatCommon.fromJson(json['category']) : null;
    _subCategory = json['sub_category'] != null ? CatSubCatCommon.fromJson(json['sub_category']) : null;
    _number = json['number'];
    _name = json['name'];
    _amount = json['amount'];
    _dateOfPayment = json['date_of_payment'];
    _comment = json['comment'];
    _active = json['active'];
    _deleted = json['deleted'];
    _updateDate = json['update_date'];
    _addedBy = json['added_by'] != null ? AddedBy.fromJson(json['added_by']) : null;
    _office = json['office'];
    if (json['file'] != null) {
      _file = [];
      json['file'].forEach((v) {
        _file?.add(v);
      });
    }
    _officeType = json['office_type'];
    _actionBy = json['action_by'];
    _reason = json['reason'];
    _expenseType = json['expense_type'];
    _platform = json['platform'];
    _id = json['_id'];
    _createdDate = json['created_date'];
    _v = json['__v'];
  }
  City? _city;
  CatSubCatCommon? _category;
  CatSubCatCommon? _subCategory;
  num? _number;
  String? _name;
  String? _amount;
  String? _dateOfPayment;
  String? _comment;
  num? _active;
  num? _deleted;
  String? _updateDate;
  AddedBy? _addedBy;
  dynamic _office;
  List<dynamic>? _file;
  String? _officeType;
  dynamic _actionBy;
  dynamic _reason;
  num? _expenseType;
  String? _platform;
  String? _id;
  String? _createdDate;
  num? _v;
Expense copyWith({  City? city,
  CatSubCatCommon? category,
  CatSubCatCommon? subCategory,
  num? number,
  String? name,
  String? amount,
  String? dateOfPayment,
  String? comment,
  num? active,
  num? deleted,
  String? updateDate,
  AddedBy? addedBy,
  dynamic office,
  List<dynamic>? file,
  String? officeType,
  dynamic actionBy,
  dynamic reason,
  num? expenseType,
  String? platform,
  String? id,
  String? createdDate,
  num? v,
}) => Expense(  city: city ?? _city,
  category: category ?? _category,
  subCategory: subCategory ?? _subCategory,
  number: number ?? _number,
  name: name ?? _name,
  amount: amount ?? _amount,
  dateOfPayment: dateOfPayment ?? _dateOfPayment,
  comment: comment ?? _comment,
  active: active ?? _active,
  deleted: deleted ?? _deleted,
  updateDate: updateDate ?? _updateDate,
  addedBy: addedBy ?? _addedBy,
  office: office ?? _office,
  file: file ?? _file,
  officeType: officeType ?? _officeType,
  actionBy: actionBy ?? _actionBy,
  reason: reason ?? _reason,
  expenseType: expenseType ?? _expenseType,
  platform: platform ?? _platform,
  id: id ?? _id,
  createdDate: createdDate ?? _createdDate,
  v: v ?? _v,
);
  City? get city => _city;
  CatSubCatCommon? get category => _category;
  CatSubCatCommon? get subCategory => _subCategory;
  num? get number => _number;
  String? get name => _name;
  String? get amount => _amount;
  String? get dateOfPayment => _dateOfPayment;
  String? get comment => _comment;
  num? get active => _active;
  num? get deleted => _deleted;
  String? get updateDate => _updateDate;
  AddedBy? get addedBy => _addedBy;
  dynamic get office => _office;
  List<dynamic>? get file => _file;
  String? get officeType => _officeType;
  dynamic get actionBy => _actionBy;
  dynamic get reason => _reason;
  num? get expenseType => _expenseType;
  String? get platform => _platform;
  String? get id => _id;
  String? get createdDate => _createdDate;
  num? get v => _v;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (_city != null) {
      map['city'] = _city?.toJson();
    }
    if (_category != null) {
      map['category'] = _category?.toJson();
    }
    if (_subCategory != null) {
      map['sub_category'] = _subCategory?.toJson();
    }
    map['number'] = _number;
    map['name'] = _name;
    map['amount'] = _amount;
    map['date_of_payment'] = _dateOfPayment;
    map['comment'] = _comment;
    map['active'] = _active;
    map['deleted'] = _deleted;
    map['update_date'] = _updateDate;
    if (_addedBy != null) {
      map['added_by'] = _addedBy?.toJson();
    }
    map['office'] = _office;
    if (_file != null) {
      map['file'] = _file?.map((v) => v.toJson()).toList();
    }
    map['office_type'] = _officeType;
    map['action_by'] = _actionBy;
    map['reason'] = _reason;
    map['expense_type'] = _expenseType;
    map['platform'] = _platform;
    map['_id'] = _id;
    map['created_date'] = _createdDate;
    map['__v'] = _v;
    return map;
  }

}

AddedBy addedByFromJson(String str) => AddedBy.fromJson(json.decode(str));
String addedByToJson(AddedBy data) => json.encode(data.toJson());
class AddedBy {
  AddedBy({
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
      List<dynamic>? multipleCity, 
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
    _multipleCity = multipleCity;
    _id = id;
    _createdDate = createdDate;
    _v = v;
    _updatedAt = updatedAt;
}

  AddedBy.fromJson(dynamic json) {
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
    if (json['multiple_city'] != null) {
      _multipleCity = [];
      json['multiple_city'].forEach((v) {
        _multipleCity?.add(v);
      });
    }
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
  List<dynamic>? _multipleCity;
  String? _id;
  String? _createdDate;
  num? _v;
  String? _updatedAt;
AddedBy copyWith({  VendorPosition? vendorPosition,
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
  List<dynamic>? multipleCity,
  String? id,
  String? createdDate,
  num? v,
  String? updatedAt,
}) => AddedBy(  vendorPosition: vendorPosition ?? _vendorPosition,
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
  multipleCity: multipleCity ?? _multipleCity,
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
  List<dynamic>? get multipleCity => _multipleCity;
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
    if (_multipleCity != null) {
      map['multiple_city'] = _multipleCity?.map((v) => v.toJson()).toList();
    }
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

VendorPosition vendorPositionFromJson(String str) => VendorPosition.fromJson(json.decode(str));
String vendorPositionToJson(VendorPosition data) => json.encode(data.toJson());
class VendorPosition {
  VendorPosition({
      String? type, 
      List<num>? coordinates,}){
    _type = type;
    _coordinates = coordinates;
}

  VendorPosition.fromJson(dynamic json) {
    _type = json['type'];
    _coordinates = json['coordinates'] != null ? json['coordinates'].cast<num>() : [];
  }
  String? _type;
  List<num>? _coordinates;
VendorPosition copyWith({  String? type,
  List<num>? coordinates,
}) => VendorPosition(  type: type ?? _type,
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

City cityFromJson(String str) => City.fromJson(json.decode(str));
String cityToJson(City data) => json.encode(data.toJson());
class City {
  City({
      String? name, 
      String? description, 
      String? descriptionAfterContent, 
      String? file, 
      String? createdDate, 
      String? updateDate, 
      num? active, 
      num? deleted, 
      String? ps, 
      bool? cod, 
      String? state, 
      String? file2, 
      num? footer, 
      String? heading, 
      String? subHeading, 
      String? footerContent, 
      String? seoTitle, 
      String? seoDescription, 
      String? seoKeywords, 
      String? extraDeliveryCharges, 
      num? hotFoodAvailable, 
      String? minimumOrderValue, 
      String? maximumCodOrderValue, 
      List<String>? slugHistory, 
      String? id, 
      String? slug, 
      num? v,}){
    _name = name;
    _description = description;
    _descriptionAfterContent = descriptionAfterContent;
    _file = file;
    _createdDate = createdDate;
    _updateDate = updateDate;
    _active = active;
    _deleted = deleted;
    _ps = ps;
    _cod = cod;
    _state = state;
    _file2 = file2;
    _footer = footer;
    _heading = heading;
    _subHeading = subHeading;
    _footerContent = footerContent;
    _seoTitle = seoTitle;
    _seoDescription = seoDescription;
    _seoKeywords = seoKeywords;
    _extraDeliveryCharges = extraDeliveryCharges;
    _hotFoodAvailable = hotFoodAvailable;
    _minimumOrderValue = minimumOrderValue;
    _maximumCodOrderValue = maximumCodOrderValue;
    _slugHistory = slugHistory;
    _id = id;
    _slug = slug;
    _v = v;
}

  City.fromJson(dynamic json) {
    _name = json['name'];
    _description = json['description'];
    _descriptionAfterContent = json['description_after_content'];
    _file = json['file'];
    _createdDate = json['created_date'];
    _updateDate = json['update_date'];
    _active = json['active'];
    _deleted = json['deleted'];
    _ps = json['ps'];
    _cod = json['cod'];
    _state = json['state'];
    _file2 = json['file2'];
    _footer = json['footer'];
    _heading = json['heading'];
    _subHeading = json['sub_heading'];
    _footerContent = json['footer_content'];
    _seoTitle = json['seo_title'];
    _seoDescription = json['seo_description'];
    _seoKeywords = json['seo_keywords'];
    _extraDeliveryCharges = json['extra_delivery_charges'];
    _hotFoodAvailable = json['hot_food_available'];
    _minimumOrderValue = json['minimum_order_value'];
    _maximumCodOrderValue = json['maximum_cod_order_value'];
    _slugHistory = json['slug_history'] != null ? json['slug_history'].cast<String>() : [];
    _id = json['_id'];
    _slug = json['slug'];
    _v = json['__v'];
  }
  String? _name;
  String? _description;
  String? _descriptionAfterContent;
  String? _file;
  String? _createdDate;
  String? _updateDate;
  num? _active;
  num? _deleted;
  String? _ps;
  bool? _cod;
  String? _state;
  String? _file2;
  num? _footer;
  String? _heading;
  String? _subHeading;
  String? _footerContent;
  String? _seoTitle;
  String? _seoDescription;
  String? _seoKeywords;
  String? _extraDeliveryCharges;
  num? _hotFoodAvailable;
  String? _minimumOrderValue;
  String? _maximumCodOrderValue;
  List<String>? _slugHistory;
  String? _id;
  String? _slug;
  num? _v;
City copyWith({  String? name,
  String? description,
  String? descriptionAfterContent,
  String? file,
  String? createdDate,
  String? updateDate,
  num? active,
  num? deleted,
  String? ps,
  bool? cod,
  String? state,
  String? file2,
  num? footer,
  String? heading,
  String? subHeading,
  String? footerContent,
  String? seoTitle,
  String? seoDescription,
  String? seoKeywords,
  String? extraDeliveryCharges,
  num? hotFoodAvailable,
  String? minimumOrderValue,
  String? maximumCodOrderValue,
  List<String>? slugHistory,
  String? id,
  String? slug,
  num? v,
}) => City(  name: name ?? _name,
  description: description ?? _description,
  descriptionAfterContent: descriptionAfterContent ?? _descriptionAfterContent,
  file: file ?? _file,
  createdDate: createdDate ?? _createdDate,
  updateDate: updateDate ?? _updateDate,
  active: active ?? _active,
  deleted: deleted ?? _deleted,
  ps: ps ?? _ps,
  cod: cod ?? _cod,
  state: state ?? _state,
  file2: file2 ?? _file2,
  footer: footer ?? _footer,
  heading: heading ?? _heading,
  subHeading: subHeading ?? _subHeading,
  footerContent: footerContent ?? _footerContent,
  seoTitle: seoTitle ?? _seoTitle,
  seoDescription: seoDescription ?? _seoDescription,
  seoKeywords: seoKeywords ?? _seoKeywords,
  extraDeliveryCharges: extraDeliveryCharges ?? _extraDeliveryCharges,
  hotFoodAvailable: hotFoodAvailable ?? _hotFoodAvailable,
  minimumOrderValue: minimumOrderValue ?? _minimumOrderValue,
  maximumCodOrderValue: maximumCodOrderValue ?? _maximumCodOrderValue,
  slugHistory: slugHistory ?? _slugHistory,
  id: id ?? _id,
  slug: slug ?? _slug,
  v: v ?? _v,
);
  String? get name => _name;
  String? get description => _description;
  String? get descriptionAfterContent => _descriptionAfterContent;
  String? get file => _file;
  String? get createdDate => _createdDate;
  String? get updateDate => _updateDate;
  num? get active => _active;
  num? get deleted => _deleted;
  String? get ps => _ps;
  bool? get cod => _cod;
  String? get state => _state;
  String? get file2 => _file2;
  num? get footer => _footer;
  String? get heading => _heading;
  String? get subHeading => _subHeading;
  String? get footerContent => _footerContent;
  String? get seoTitle => _seoTitle;
  String? get seoDescription => _seoDescription;
  String? get seoKeywords => _seoKeywords;
  String? get extraDeliveryCharges => _extraDeliveryCharges;
  num? get hotFoodAvailable => _hotFoodAvailable;
  String? get minimumOrderValue => _minimumOrderValue;
  String? get maximumCodOrderValue => _maximumCodOrderValue;
  List<String>? get slugHistory => _slugHistory;
  String? get id => _id;
  String? get slug => _slug;
  num? get v => _v;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['name'] = _name;
    map['description'] = _description;
    map['description_after_content'] = _descriptionAfterContent;
    map['file'] = _file;
    map['created_date'] = _createdDate;
    map['update_date'] = _updateDate;
    map['active'] = _active;
    map['deleted'] = _deleted;
    map['ps'] = _ps;
    map['cod'] = _cod;
    map['state'] = _state;
    map['file2'] = _file2;
    map['footer'] = _footer;
    map['heading'] = _heading;
    map['sub_heading'] = _subHeading;
    map['footer_content'] = _footerContent;
    map['seo_title'] = _seoTitle;
    map['seo_description'] = _seoDescription;
    map['seo_keywords'] = _seoKeywords;
    map['extra_delivery_charges'] = _extraDeliveryCharges;
    map['hot_food_available'] = _hotFoodAvailable;
    map['minimum_order_value'] = _minimumOrderValue;
    map['maximum_cod_order_value'] = _maximumCodOrderValue;
    map['slug_history'] = _slugHistory;
    map['_id'] = _id;
    map['slug'] = _slug;
    map['__v'] = _v;
    return map;
  }

}