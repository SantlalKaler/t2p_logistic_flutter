import 'package:t2p_logistic/domain/Model/AF2APOrderResponse.dart';
import 'package:t2p_logistic/domain/Model/T2POrderResponse.dart';
import 'package:t2p_logistic/presentation/constants/extension.dart';
import 'package:t2p_logistic/presentation/theme/resource/custom_constants.dart';

extension T2POrderExtension on T2POrder {
  CommonOrder? toCommonOrder() {
    var productList = "";
    for (var i = 0; i < products!.length; i++) {
      productList += "${i + 1}. ${products![i].productname}";
    }
    try {
      printValue("Delivery boy is $deliveryBoy\n"
          "Pickup boy is $pickupBoy");
      return CommonOrder(
          id: id ?? "",
          orderId: orderid ?? "",
          productNames: productList,
          createdAt: createdDate!.toDate(outputDate: "dd-MM-yyyy HH:mm:ss"),
          pickupAddress: vendor?.address ?? "",
          deliveryAddress: address?.city?.name ?? "",
          price: finalprice ?? "",
          pickupWeight: pickupWeight ?? "",
          deliveryWeight: deliveryWeight ?? "",
          deliveryZipcode: address?.pincode ?? "",
          customerNumber: user?.mobile ?? "",
          customerAddress: "${user?.fullName}, ${user?.address}",
          express: express ?? "N",
          paymentMode: gateway ?? "",
          deliveryDate: deliveryDate?.toDate() ?? "",
          deliveryTime: timeslot ?? "",
          orderStatus: status?.toUpperCase() ?? "",
          pickupBoy: pickupBoy?.fullName ?? "Unassigned",
          deliveryBoy: deliveryBoy?.fullName ?? "Unassigned"
      );
    } catch (e) {
      printValue("Error is : $e");
      return null;
    }
  }
}

extension AF2APOrderExtension on AF2APOrder {
  CommonOrder? toCommonOrder() {
    var productList = "";
    for (var i = 0; i < products!.length; i++) {
      productList += "${i + 1}. ${products![i].name}";
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
          createdAt: createdAt!.toDate(outputDate: "dd-MM-yyyy HH:mm:ss"),
          pickupAddress: sourceLocation?.city?.name ?? "",
          deliveryAddress: destinationLocation?.city?.name ?? "",
          price: totalPrice ?? "",
          pickupWeight: totalWeight ?? "",
          deliveryWeight: totalWeight ?? "",
          deliveryZipcode: destinationLocation?.pincode ?? "",
          customerNumber: user?.mobile ?? "",
          customerAddress: "${user?.fullName}, ${user?.address}",
          express: express,
          paymentMode: "",
          deliveryDate: deliveryDate?.toDate() ?? "",
          deliveryTime: deliveryTimeslot ?? "",
          orderStatus: status?.toUpperCase() ?? "",
          pickupBoy: pickupBoy?.fullName ?? "Unassigned",
          deliveryBoy: deliveryBoy?.fullName ?? "Unassigned",
      );
    } catch (e) {
      printValue("Error is : $e");
      return null;
    }
  }
}

class CommonOrder {
  String id;
  String orderId;
  String productNames;
  String createdAt;
  String pickupAddress;
  String deliveryAddress;
  String price;
  String pickupWeight;
  String deliveryWeight;
  String deliveryZipcode;
  String customerNumber;
  String customerAddress;
  String express;
  String paymentMode;
  String deliveryDate;
  String deliveryTime;
  String orderStatus;
  String pickupBoy;
  String deliveryBoy;

  CommonOrder({
    required this.orderId,
    required this.id,
    required this.productNames,
    required this.createdAt,
    required this.pickupAddress,
    required this.deliveryAddress,
    required this.price,
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
  });
}
