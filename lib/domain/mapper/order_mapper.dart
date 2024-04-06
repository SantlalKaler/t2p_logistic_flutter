import 'package:t2p_logistic/domain/Model/AF2APOrderResponse.dart'
    as af2apResponse;
import 'package:t2p_logistic/domain/Model/T2POrderResponse.dart';
import 'package:t2p_logistic/presentation/constants/extension.dart';
import 'package:t2p_logistic/presentation/theme/resource/custom_constants.dart';

import '../Model/user/AddressListResponse.dart';

extension T2POrderExtension on T2POrder {
  CommonOrder? toCommonOrder() {
    var productList = "";
    for (var i = 0; i < products!.length; i++) {
      productList +=
          "${i + 1}. (Qty : ${products?[i].quantity}) ${products![i].productname}\n";
    }
    try {
      /*printValue("Delivery boy is $deliveryBoy\n"
          "Pickup boy is $pickupBoy");*/
      return CommonOrder(
          id: id ?? "",
          orderId: orderid ?? "",
          productNames: productList,
          createdAt: createdDate!.toDate(outputDate: "dd-MM-yyyy hh:mm:ss"),
          pickupCity: vendor?.address ?? "",
          deliveryCity: address?.city?.name ?? "",
          price: finalprice ?? "",
          pickupWeight: pickupWeight ?? "",
          deliveryWeight: deliveryWeight ?? "",
          deliveryZipcode: address?.pincode ?? "",
          customerNumber: user?.mobile ?? "",
          customerAddress:
              "${address?.contactName}, \n${address?.address}, \n${address?.address2},\n${address?.pincode}, ${address?.landmark}, \n${address?.postOffice}, \n${address?.city?.name},${address?.state?.name},",
          express: express ?? "N",
          paymentMode: gateway ?? "",
          deliveryDate: deliveryDate?.toDate() ?? "",
          deliveryTime: timeslot ?? "",
          orderStatus: status?.toUpperCase() ?? "",
          pickupBoy: pickupBoy?.fullName ?? "Unassigned",
          deliveryBoy: deliveryBoy?.fullName ?? "Unassigned",
          deliveryPartner: deliveryPartner?.fullName ?? "",
          lpManager: lpManager?.fullName ?? "",
          pickupAddress: Address(),
          deliveryAddress: address ?? Address());
    } catch (e) {
      printValue("Error is : $e");
      return null;
    }
  }
}

extension AF2APOrderExtension on af2apResponse.AF2APOrder {
  CommonOrder? toCommonOrder() {
    var productList = "";
    for (var i = 0; i < products!.length; i++) {
      productList += "${i + 1}. ${products![i].name}\n";
    }

    var express = "N";
    if (deliveryType == "express") {
      express = "Y";
    }

    try {
      return CommonOrder(
          id: id ?? "",
          orderId: orderid ?? "",
          productNames: productList,
          createdAt: createdAt!.toDate(outputDate: "dd-MM-yyyy hh:mm:ss"),
          pickupCity: sourceLocation?.city?.name ?? "",
          deliveryCity: destinationLocation?.city?.name ?? "",
          price: totalPrice ?? "",
          duesAmount: duesAmount ?? "",
          paidAmount: paidAmount ?? "",
          pickupWeight: totalWeight ?? "",
          deliveryWeight: totalWeight ?? "",
          deliveryZipcode: destinationLocation?.pincode ?? "",
          customerNumber: user?.mobile ?? "",
          customerAddress: "${user?.fullName}, ${user?.address}",
          express: express,
          paymentMode: "COD",
          deliveryDate: deliveryDate?.toDate() ?? "",
          deliveryTime: deliveryTimeslot ?? "",
          orderStatus: status?.toUpperCase() ?? "",
          pickupBoy: pickupBoy?.fullName ?? "Unassigned",
          deliveryBoy: deliveryBoy?.fullName ?? "Unassigned",
          pickupAddress: sourceLocation ?? Address(),
          deliveryAddress: destinationLocation ?? Address(),
          af2apProducts: products);
    } catch (e) {
      printValue("Error is : $e");
      return null;
    }
  }
}

class CommonOrder {
  String? id;
  String? orderId;
  String? productNames;
  String? createdAt;
  String? pickupCity;
  String? deliveryCity;
  String? price;
  String? duesAmount;
  String? paidAmount;
  String? pickupWeight;
  String? deliveryWeight;
  String? deliveryZipcode;
  String? customerNumber;
  String? customerAddress;
  String? express;
  String? paymentMode;
  String? deliveryDate;
  String? deliveryTime;
  String? orderStatus;
  String? pickupBoy;
  String? deliveryBoy;
  String? lpManager;
  String? deliveryPartner;
  Address? pickupAddress;
  Address? deliveryAddress;
  List<af2apResponse.Products>? af2apProducts;

  CommonOrder({
    required this.orderId,
    required this.id,
    required this.productNames,
    required this.createdAt,
    required this.pickupCity,
    required this.deliveryCity,
    required this.price,
    this.duesAmount,
    this.paidAmount,
    required this.pickupWeight,
    required this.deliveryWeight,
    required this.deliveryZipcode,
    required this.customerNumber,
    required this.customerAddress,
    required this.express,
    required this.paymentMode,
    required this.deliveryDate,
    required this.deliveryTime,
    required this.orderStatus,
    required this.pickupBoy,
    required this.deliveryBoy,
    this.deliveryPartner,
    this.lpManager,
    required this.pickupAddress,
    required this.deliveryAddress,
    this.af2apProducts,
  });
}
