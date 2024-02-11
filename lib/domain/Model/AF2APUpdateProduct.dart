import 'dart:convert';
Af2apUpdateProduct af2apUpdateProductFromJson(String str) => Af2apUpdateProduct.fromJson(json.decode(str));
String af2apUpdateProductToJson(Af2apUpdateProduct data) => json.encode(data.toJson());
class Af2apUpdateProduct {
  Af2apUpdateProduct({
      String? orderId, 
      List<Products>? products,}){
    _orderId = orderId;
    _products = products;
}

  Af2apUpdateProduct.fromJson(dynamic json) {
    _orderId = json['orderId'];
    if (json['products'] != null) {
      _products = [];
      json['products'].forEach((v) {
        _products?.add(Products.fromJson(v));
      });
    }
  }
  String? _orderId;
  List<Products>? _products;
Af2apUpdateProduct copyWith({  String? orderId,
  List<Products>? products,
}) => Af2apUpdateProduct(  orderId: orderId ?? _orderId,
  products: products ?? _products,
);
  String? get orderId => _orderId;
  List<Products>? get products => _products;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['orderId'] = _orderId;
    if (_products != null) {
      map['products'] = _products?.map((v) => v.toJson()).toList();
    }
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
      String? category, 
      String? subCategory,}){
    _name = name;
    _weight = weight;
    _height = height;
    _weidth = weidth;
    _length = length;
    _category = category;
    _subCategory = subCategory;
}

  Products.fromJson(dynamic json) {
    _name = json['name'];
    _weight = json['weight'];
    _height = json['height'];
    _weidth = json['weidth'];
    _length = json['length'];
    _category = json['category'];
    _subCategory = json['sub_category'];
  }
  String? _name;
  String? _weight;
  String? _height;
  String? _weidth;
  String? _length;
  String? _category;
  String? _subCategory;
Products copyWith({  String? name,
  String? weight,
  String? height,
  String? weidth,
  String? length,
  String? category,
  String? subCategory,
}) => Products(  name: name ?? _name,
  weight: weight ?? _weight,
  height: height ?? _height,
  weidth: weidth ?? _weidth,
  length: length ?? _length,
  category: category ?? _category,
  subCategory: subCategory ?? _subCategory,
);
  String? get name => _name;
  String? get weight => _weight;
  String? get height => _height;
  String? get weidth => _weidth;
  String? get length => _length;
  String? get category => _category;
  String? get subCategory => _subCategory;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['name'] = _name;
    map['weight'] = _weight;
    map['height'] = _height;
    map['weidth'] = _weidth;
    map['length'] = _length;
    map['category'] = _category;
    map['sub_category'] = _subCategory;
    return map;
  }

}