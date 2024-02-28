import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:t2p_logistic/data/api_services.dart';
import 'package:t2p_logistic/data/status.dart';
import 'package:t2p_logistic/domain/Model/AF2APOrderResponse.dart'
    as aF2APOrderResponse;
import 'package:t2p_logistic/domain/Model/AllDeliveryStatusResponse.dart';
import 'package:t2p_logistic/domain/Model/T2POrderResponse.dart';
import 'package:t2p_logistic/domain/enums/user_type.dart';
import 'package:t2p_logistic/domain/mapper/order_mapper.dart';
import 'package:t2p_logistic/presentation/controllers/user_controller.dart';
import 'package:t2p_logistic/presentation/theme/resource/strings_constants.dart';
import 'package:t2p_logistic/presentation/theme/resource/uri_constants.dart';
import 'package:t2p_logistic/presentation/widgets/custom_snackbar.dart';

import '../../../domain/Model/single_filter_item.dart';
import '../../constants/view_constants.dart';
import '../../theme/resource/custom_constants.dart';
import '../address/map_location_controller.dart';

ApiService _apiService = ApiService();

class OrderController extends GetxController {
  RxBool pickupLoading = false.obs;
  RxBool deliveryLoading = false.obs;
  RxBool buttonLoading = false.obs;
  RxBool dialogLoading = false.obs;
  RxBool phonePePaymentSuccess = false.obs;
  RxString qrAvailable = "".obs;
  String txnId = "";
  RxBool updateButtonLoading = false.obs;
  RxBool selectAllOrders = false.obs;

  UserController userController = Get.find();

  RxBool gharKaKhanaCheck = false.obs;

  // here we create 2 list
  // 1 for original list and 1 for filter list
  // when user apply any filter then we update filter list
  // and the actual data is store in another list
  RxList<CommonOrder> t2pPickupOrders = RxList<CommonOrder>();
  RxList<CommonOrder> t2pPickupFilterOrders = RxList<CommonOrder>();
  RxList<CommonOrder> t2pDeliveryOrders = RxList<CommonOrder>();
  RxList<CommonOrder> t2pDeliveryFilterOrders = RxList<CommonOrder>();
  RxList<CommonOrder> aF2APPickupFilterOrders = RxList<CommonOrder>();
  RxList<CommonOrder> aF2APDeliveryFilterOrders = RxList<CommonOrder>();
  RxList<String> orderIds = RxList<String>();
  RxList<String> pickupOrderStatus = RxList<String>();

  RxList<String> lpManager = RxList<String>();
  RxList<String> deliveryPartner = RxList<String>();
  RxString selectedManger = "LP Manager".obs;
  RxString selectedPartner = "Delivery Partner".obs;

  RxList<String> deliveryOrderStatus = RxList<String>();
  RxList<String> t2pPickupSelectedOrderIds = RxList<String>();
  RxList<String> t2pDeliverSelectedOrderIds = RxList<String>();
  RxList<String> aF2APDeliverSelectedOrderIds = RxList<String>();
  RxList<String> aF2APPickupSelectedOrderIds = RxList<String>();

  Rxn<AllDeliveryStatusResponse> allDeliveryStatusResponse =
      Rxn<AllDeliveryStatusResponse>();

  RxString pickupSelectedOrderStatus = "".obs;
  RxString deliverySelectedOrderStatus = "".obs;

  T2POrderType t2pOrderType = T2POrderType.T2P;
  OrderType orderType = OrderType.pickup;
  PaymentType paymentType = PaymentType.COD;

  setPickupLoading() => pickupLoading.value = !pickupLoading.value;

  setDeliveryLoading() => deliveryLoading.value = !deliveryLoading.value;

  setButtonLoading() => buttonLoading.value = !buttonLoading.value;

  setDialogLoading() => dialogLoading.value = !dialogLoading.value;

  setUpdateButtonLoading() =>
      updateButtonLoading.value = !updateButtonLoading.value;

  @override
  void onInit() {
    super.onInit();
    // if any order is already started from boy then send location simultaneously
    /*if (userController.orderAlreadyStarted) {
      Timer.periodic(const Duration(seconds: 3), (timer) {
        mapLocationController.sendLocationToFirebase();
      });
    }*/
  }

  changePaymentType(PaymentType type) async {
    qrAvailable.value = "";
    paymentType = type;
    update();
    // if payment type is QR then we need to get the payment QR code
    if (type == PaymentType.QR) {
      await generateQRCode();
    }
  }

  filterOrder(UserType userType, String value) {
    List<CommonOrder> filterOrders = [];
    for (var order in t2pPickupOrders) {
      if (userType == UserType.lp_manager && order.lpManager == value) {
        selectedManger.value = value;
        filterOrders.add(order);
      } else if (userType == UserType.delivery_partner &&
          order.deliveryPartner == value) {
        selectedPartner.value = value;
        filterOrders.add(order);
      }
    }

    t2pPickupFilterOrders.assignAll(filterOrders);
    update();
  }

  clearFilter() {
    selectedManger.value = "LP Manager";
    selectedPartner.value = "Delivery Partner";
    t2pPickupFilterOrders.assignAll(List.from(t2pPickupOrders));
    update();
  }

  List<FilterItem> getChipList() {
    var chipList = [
      FilterItem(title: t2pOrderType.name, id: FilterItemId.orderType),
    ];

    // only partner and delivery boy can print his orders
    if (userController.userType == UserType.delivery_boy.name ||
        userController.userType == UserType.delivery_partner.name) {
      FilterItem(title: "Print", id: FilterItemId.print);
    }

    // delivery partner can change order status
    if (userController.userType == UserType.delivery_partner.name) {
      chipList.add(FilterItem(title: "Change Status", id: FilterItemId.status));
    }

    // lp head can filter order according to lp manager and delivery partner
    // but first lp-head need to select lp manager after that he can select
    // delivery partner because delivery partner come under lp manager
    if (userController.userType == UserType.lp_head.name) {
      chipList.add(
          FilterItem(title: selectedManger.value, id: FilterItemId.lpManager));
    }

    // lp manager can filter order according to delivery partner
    if (userController.userType == UserType.lp_head.name ||
        userController.userType == UserType.lp_manager.name) {
      chipList.add(FilterItem(
          title: selectedPartner.value, id: FilterItemId.deliveryPartner));
    }

    return chipList;
  }

  // --------------------- Select Order Id --------------------
  bool orderSelected(String orderId) {
    bool orderSelected = false;
    if (t2pOrderType == T2POrderType.T2P) {
      if (orderType == OrderType.pickup &&
          t2pPickupSelectedOrderIds.contains(orderId)) {
        orderSelected = true;
      } else if (orderType == OrderType.deliver &&
          t2pDeliverSelectedOrderIds.contains(orderId)) {
        orderSelected = true;
      }
    } else {
      if (orderType == OrderType.pickup &&
          aF2APPickupSelectedOrderIds.contains(orderId)) {
        orderSelected = true;
      } else if (orderType == OrderType.deliver &&
          aF2APDeliverSelectedOrderIds.contains(orderId)) {
        orderSelected = true;
      }
    }

    return orderSelected;
  }

  bool allOrderSelected() {
    bool selected = false;

    if (t2pOrderType == T2POrderType.T2P) {
      if (orderType == OrderType.pickup &&
          t2pPickupFilterOrders.length == t2pPickupSelectedOrderIds.length &&
          t2pPickupFilterOrders.isNotEmpty) {
        selected = true;
      } else if (orderType == OrderType.deliver &&
          t2pDeliveryFilterOrders.length == t2pDeliverSelectedOrderIds.length &&
          t2pDeliveryFilterOrders.isNotEmpty) {
        selected = true;
      }
    } else {
      if (orderType == OrderType.pickup &&
          aF2APPickupFilterOrders.length ==
              aF2APPickupSelectedOrderIds.length &&
          aF2APPickupFilterOrders.isNotEmpty) {
        selected = true;
      } else if (orderType == OrderType.deliver &&
          aF2APDeliveryFilterOrders.length ==
              aF2APDeliverSelectedOrderIds.length &&
          aF2APDeliveryFilterOrders.isNotEmpty) {
        selected = true;
      }
    }

    return selected;
  }

  selectOrder(String orderId) {
    if (t2pOrderType == T2POrderType.T2P) {
      // T2P Pickup Order
      if (orderType == OrderType.pickup) {
        if (t2pPickupSelectedOrderIds.contains(orderId)) {
          t2pPickupSelectedOrderIds.remove(orderId);
        } else {
          t2pPickupSelectedOrderIds.add(orderId);
        }
        printValue("t2p pickup selected id contains\nOrder id is : $orderId\n"
            "T2P Pickup Select Order list if $t2pPickupSelectedOrderIds");
      }
      // T2P Delivery Order
      else {
        if (t2pDeliverSelectedOrderIds.contains(orderId)) {
          t2pDeliverSelectedOrderIds.remove(orderId);
        } else {
          t2pDeliverSelectedOrderIds.add(orderId);
        }
      }
    } else {
      if (orderType == OrderType.pickup) {
        if (aF2APPickupSelectedOrderIds.contains(orderId)) {
          aF2APPickupSelectedOrderIds.remove(orderId);
        } else {
          aF2APPickupSelectedOrderIds.add(orderId);
        }
      }
      // T2P Delivery Order
      else {
        if (aF2APDeliverSelectedOrderIds.contains(orderId)) {
          aF2APDeliverSelectedOrderIds.remove(orderId);
        } else {
          aF2APDeliverSelectedOrderIds.add(orderId);
        }
      }
    }
    update();

    printValue("Select order : $orderId\n"
        "T2P Order Type : $t2pOrderType\n"
        "Order Type : $orderType\n"
        "T2P Pickup Contains : ${t2pPickupSelectedOrderIds.contains(orderId)}\n"
        "T2P Deliver Contains : ${t2pDeliverSelectedOrderIds.contains(orderId)}\n"
        "AF2AP Deliver Contains : ${aF2APPickupSelectedOrderIds.contains(orderId)}\n"
        "AF2AP Deliver Contains : ${aF2APDeliverSelectedOrderIds.contains(orderId)}\n");
  }

  changeSelectAllOrders(bool selectAll) {
    selectAllOrders.value = !selectAllOrders.value;

    if (t2pOrderType == T2POrderType.T2P) {
      if (orderType == OrderType.pickup) {
        t2pPickupSelectedOrderIds.clear();
        if (selectAll) {
          for (var order in t2pPickupFilterOrders) {
            t2pPickupSelectedOrderIds.add(order.id!);
          }
        }
      } else {
        t2pDeliverSelectedOrderIds.clear();
        if (selectAll) {
          for (var order in t2pDeliveryFilterOrders) {
            t2pDeliverSelectedOrderIds.add(order.id!);
          }
        }
      }
    } else {
      if (orderType == OrderType.pickup) {
        aF2APPickupSelectedOrderIds.clear();
        if (selectAll) {
          for (var order in aF2APPickupFilterOrders) {
            aF2APPickupSelectedOrderIds.add(order.id!);
          }
        }
      } else {
        aF2APDeliverSelectedOrderIds.clear();
        if (selectAll) {
          for (var order in aF2APDeliveryFilterOrders) {
            selectOrder(order.id!);
          }
        }
      }
    }
    update();
  }

  // ----------------------------------------------------------

  changeGharKaKhanaValue(bool value) {
    gharKaKhanaCheck.value = value;
    update();
  }

  changeT2POrderType(T2POrderType value) {
    t2pOrderType = value;
    update();
    getOrders();
  }

  changeOrderType(int index) {
    if (index == 0) {
      orderType = OrderType.pickup;
    } else {
      orderType = OrderType.deliver;
    }
    update();
    getOrders();
  }

  getOrders() {
    /*  printValue(
        "T2P Order Type : $t2pOrderType\n"
        "Order Type : $orderType\n");*/

    switch (t2pOrderType) {
      case T2POrderType.T2P:
        if (orderType == OrderType.pickup && t2pPickupFilterOrders.isEmpty) {
          getT2POrders();
        } else if (orderType == OrderType.deliver &&
            t2pDeliveryFilterOrders.isEmpty) {
          getT2POrders(orderType: OrderType.deliver);
        }
        break;
      case T2POrderType.AF2AP:
        if (orderType == OrderType.pickup && aF2APPickupFilterOrders.isEmpty) {
          getAF2APOrders();
        } else if (orderType == OrderType.deliver &&
            aF2APDeliveryFilterOrders.isEmpty) {
          getAF2APOrders(orderType: OrderType.deliver);
        }
        break;
    }
  }

  String getOrderPath(
      {T2POrderType t2pOrderType = T2POrderType.T2P,
      OrderType orderType = OrderType.pickup}) {
    String userType = userController.userType;
    var path = URIConstants.partnerPickupOrder;

    //if user type is partner and t2p order type is t2p and order type is pickup
    if (userType == UserType.delivery_partner.name) {
      if (t2pOrderType == T2POrderType.T2P) {
        if (orderType == OrderType.pickup) {
          path = URIConstants.partnerPickupOrder;
        } else {
          path = URIConstants.partnerDeliveryOrder;
        }
      }
      // if t2p order type is af2ap(ghar ka khana)
      else {
        if (orderType == OrderType.pickup) {
          path = URIConstants.partnerPickupOrderAF2AP;
        } else {
          path = URIConstants.partnerDeliveryOrderAF2AP;
        }
      }
    }
    // if user type is delivery boy
    else if (userController.userType == UserType.delivery_boy.name) {
      if (t2pOrderType == T2POrderType.T2P) {
        if (orderType == OrderType.pickup) {
          path = URIConstants.boyPickupOrderT2P;
        } else {
          path = URIConstants.boyDeliveryOrderT2P;
        }
      }
      // if t2p order type is af2ap(ghar ka khana)
      else {
        if (orderType == OrderType.pickup) {
          path = URIConstants.boyPickupOrderAF2AP;
        } else {
          path = URIConstants.boyDeliveryOrderAF2AP;
        }
      }
    }

    // if user type is lp head
    else if (userController.userType == UserType.lp_head.name ||
        userController.userType == UserType.lp_manager.name) {
      if (t2pOrderType == T2POrderType.T2P) {
        path = URIConstants.lpOrder;
      }
    }

    return path;
  }

  Future getT2POrders({OrderType orderType = OrderType.pickup}) async {
    if (orderType == OrderType.pickup) {
      setPickupLoading();
    } else {
      setDeliveryLoading();
    }

    update();
    try {
      //set path according to user and order type
      var path = getOrderPath(orderType: orderType);

      var userId = userController.userId;

      // if user type is delivery boy or delivery partner
      var data = {"id": userId};

      // if user type is lp head
      if (userController.userType == UserType.lp_head.name) {
        path += "?lp_head=$userId";
      }
      if (userController.userType == UserType.lp_manager.name) {
        path += "?lp_manager=$userId";
      }

      // for lp head and manger api is get type with query parameters
      var response = (userController.userType == UserType.lp_head.name ||
              userController.userType == UserType.lp_manager.name)
          ? await _apiService.get(path)
          : await _apiService.post(path, data);

      if (response != null && response.data['status'] == Status.success.name) {
        //clear order list
        clearList(t2pOrderType, orderType);

        T2pOrderResponse t2pOrderResponse =
            T2pOrderResponse.fromJson(response.data);

        if (t2pOrderResponse.order!.isNotEmpty) {
          // for partner we need to get status so partner can change order status
          if (userController.userType == UserType.delivery_partner.name) {
            await allDeliveryStatus();
          }

          for (var order in t2pOrderResponse.order!) {
            var orderAfterConvert = order.toCommonOrder();
            if (order.deliveryPartner != null &&
                !deliveryPartner.contains(order.deliveryPartner!.fullName)) {
              deliveryPartner.add(order.deliveryPartner!.fullName!);
            }
            if (order.lpManager != null &&
                !lpManager.contains(order.lpManager!.fullName)) {
              lpManager.add(order.lpManager!.fullName!);
            }
            if (orderAfterConvert != null) {
              if (orderType == OrderType.pickup) {
                t2pPickupOrders.add(orderAfterConvert);
              } else {
                t2pDeliveryOrders.add(orderAfterConvert);
              }
            }
          }
        }

        printValue("Delivery partner list $deliveryPartner\n"
            "Lp Manager list : $lpManager");

        t2pPickupFilterOrders.assignAll(List.from(t2pPickupOrders));
        t2pDeliveryFilterOrders.assignAll(List.from(t2pDeliveryOrders));
      } else {
        CustomSnackBar.showSnackBar(
            CustomSnackBar.error, "No Order Found", CustomSnackBar.error);
      }
      update();
    } finally {
      if (orderType == OrderType.pickup) {
        setPickupLoading();
      } else {
        setDeliveryLoading();
      }
      update();
    }
  }

  clearList(T2POrderType t2pOrderType, OrderType orderType) {
    // orderToBeAssign.clear();
    if (t2pOrderType == T2POrderType.T2P) {
      if (orderType == OrderType.pickup) {
        t2pPickupFilterOrders.clear();
        pickupOrderStatus.clear();
      } else {
        deliveryOrderStatus.clear();
        t2pDeliveryFilterOrders.clear();
      }
    }
    // AF2AP
    else {
      if (orderType == OrderType.pickup) {
        pickupOrderStatus.clear();
        aF2APPickupFilterOrders.clear();
      } else {
        deliveryOrderStatus.clear();
        aF2APDeliveryFilterOrders.clear();
      }
    }
  }

  Future getAF2APOrders({OrderType orderType = OrderType.pickup}) async {
    if (orderType == OrderType.pickup) {
      setPickupLoading();
    } else {
      setDeliveryLoading();
    }
    update();

    try {
      var path =
          getOrderPath(t2pOrderType: T2POrderType.AF2AP, orderType: orderType);

      // parameter name change according to user
      var userId = userController.userId;
      var data = userController.userType == UserType.delivery_partner.name &&
              orderType == OrderType.deliver
          ? {"delivery_partner": userId}
          : userController.userType == UserType.delivery_partner.name &&
                  orderType == OrderType.pickup
              ? {"pickup_partner": userId}
              : userController.userType == UserType.delivery_boy.name &&
                      orderType == OrderType.deliver
                  ? {"delivery_boy": userId}
                  : {"pickup_boy": userId};

      var response = await _apiService.post(path, {},
          hasQueryParam: true, queryParam: data);
      if (response != null) {
        aF2APOrderResponse.Af2apOrderResponse af2apOrderResponse =
            aF2APOrderResponse.Af2apOrderResponse.fromJson(response.data);

        printValue(
            "Ghar ka khana total count is ${af2apOrderResponse.totalCount}");

        if (af2apOrderResponse.order != null &&
            af2apOrderResponse.order!.isNotEmpty) {
          //clear list
          clearList(t2pOrderType, orderType);

          for (var order in af2apOrderResponse.order!) {
            var orderAfterConvert = order.toCommonOrder();
            //printValue("Order After Convert $orderAfterConvert");
            if (orderAfterConvert != null) {
              if (orderType == OrderType.pickup) {
                aF2APPickupFilterOrders.add(orderAfterConvert);
              } else {
                aF2APDeliveryFilterOrders.add(orderAfterConvert);
              }
            }
          }
        }
      }

      update();
    } finally {
      if (orderType == OrderType.pickup) {
        setPickupLoading();
      } else {
        setDeliveryLoading();
      }
      update();
    }
  }

  Future allDeliveryStatus() async {
    try {
      var response = await _apiService.get(URIConstants.allDeliveryStatus);

      if (response != null) {
        allDeliveryStatusResponse.value =
            AllDeliveryStatusResponse.fromJson(response.data);
        if (allDeliveryStatusResponse.value?.result != null) {
          var result = allDeliveryStatusResponse.value!.result!;
          if (orderType == OrderType.pickup) {
            pickupOrderStatus.clear();
            pickupOrderStatus.add(result.pickupBoyAssigned!);
            pickupOrderStatus.add(result.pickupBoyStarted!);
            pickupOrderStatus.add(result.deliveredToCargoPartner!);
            pickupOrderStatus.add(result.cargoDeliveryStarted!);
          } else {
            deliveryOrderStatus.clear();
            deliveryOrderStatus.add(result.receivedDestinationAirport!);
            deliveryOrderStatus.add(result.deliveredToDeliveryPartner!);
            deliveryOrderStatus.add(result.deliveryBoyAssigned!);
          }
        }
      }
    } finally {}
  }

  getExactStatusKey(String status) {
    for (var entry
        in allDeliveryStatusResponse.value!.result!.toJson().entries) {
      if (entry.value == status) {
        partnerStatusChange(entry.key);
      }
    }
  }

  Future partnerStatusChange(String status) async {
    setButtonLoading();
    try {
      var data = {
        "by": getUserType(),
        "id": getOrderIds(),
        "status": getStatus(status)
      };
      var response =
          await _apiService.post(URIConstants.partnerStatusChange, data);

      CustomSnackBar.showSnackBar(CustomSnackBar.error,
          response?.data[StringConstants.message], CustomSnackBar.error);
      if (response != null &&
          response.data[StringConstants.status] == Status.success.name) {
        clearList(t2pOrderType, orderType);
        getOrders();
      }
    } finally {
      setButtonLoading();
    }
  }

  // ------------------------------- Assign Order -------------------------------

  Future printOrder(PrintInvoiceType invoiceType) async {
    setButtonLoading();
    try {
      var url = "${URIConstants.pdfBaseURI}${invoiceType.name}";
      var userId = userController.userId;
      if (userController.userType == UserType.delivery_partner.name) {
        url += "?pickup_partner=$userId";
        if (t2pOrderType == T2POrderType.T2P) {
          if (orderType == OrderType.pickup) {}
        }
      } else {
        url += "?pickup_boy=$userId";
        if (t2pOrderType == T2POrderType.T2P) {
          if (orderType == OrderType.pickup) {}
        }
      }

      await openUrl(url);
    } finally {
      setButtonLoading();
    }
  }

  // ------------------------------- Assign Order -------------------------------

  RxList<String> orderToBeAssign = RxList<String>();

  bool canAssignOrStart() {
    //orderToBeAssign.clear();
    if (t2pOrderType == T2POrderType.T2P) {
      if (orderType == OrderType.pickup) {
        printValue("T2P Pickup Selected $t2pPickupSelectedOrderIds");
        orderToBeAssign = t2pPickupSelectedOrderIds;
      } else {
        printValue("T2P Delivery Selected $t2pDeliverSelectedOrderIds");
        orderToBeAssign = t2pDeliverSelectedOrderIds;
      }
    } else {
      if (orderType == OrderType.pickup) {
        printValue("AF2AP Pickup Selected $aF2APPickupSelectedOrderIds");
        orderToBeAssign = aF2APPickupSelectedOrderIds;
      } else {
        printValue("AF2AP Delivery Selected $aF2APDeliverSelectedOrderIds");
        orderToBeAssign = aF2APDeliverSelectedOrderIds;
      }
    }

    printValue("T2P Order Type : $t2pOrderType\n"
        "Order type : $orderType\n"
        "Order to be assign $orderToBeAssign\n");

    return orderToBeAssign.isNotEmpty;
  }

  String getOrderIds() {
    return orderToBeAssign.length > 1
        ? orderToBeAssign.join(",")
        : orderToBeAssign.first;
  }

  String getStatus(String status) {
    List<String> statusList = List.filled(orderToBeAssign.length, status);
    return statusList.length > 1 ? statusList.join(",") : statusList.first;
  }

  String getUserType() {
    List<String> userTypeList =
        List.filled(orderToBeAssign.length, userController.userType);
    return userTypeList.length > 1
        ? userTypeList.join(",")
        : userTypeList.first;
  }

  Future assignOrder(String boy) async {
    setButtonLoading();
    try {
      // parameters
      Map<String, String> data = {"id": getOrderIds()};
      var path = "";
      if (t2pOrderType == T2POrderType.T2P) {
        if (orderType == OrderType.pickup) {
          data["pickup_boy"] = boy;
          path = URIConstants.assignT2PPickupOrder;
        } else {
          data["delivery_boy"] = boy;
          data["user_id"] = userController.userId;
          path = URIConstants.assignT2PDeliveryOrder;
        }
      } else {
        if (orderType == OrderType.pickup) {
          data["pickup_boy"] = boy;
          path = URIConstants.assignAF2APPickupOrder;
        } else {
          data["delivery_boy"] = boy;
          path = URIConstants.assignAF2APDeliveryOrder;
        }
      }

      //api call
      var response = await _apiService.post(path, data);

      CustomSnackBar.showSnackBar(CustomSnackBar.error,
          response?.data[StringConstants.message], CustomSnackBar.error);
      if (response != null &&
          response.data[StringConstants.status] == Status.success.name) {
        clearList(t2pOrderType, orderType);
        getOrders();
      }

      //update();
    } finally {
      setButtonLoading();
      //update();
    }
  }

  Future markAsDelivered() async {
    try {
      setButtonLoading();
      var data = {"id": orderToBeAssign.last, "user_id": userController.userId};

      var response = await _apiService.post(URIConstants.changeOrderStatus, {},
          hasQueryParam: true, queryParam: data);

      CustomSnackBar.showSnackBar(CustomSnackBar.error,
          response?.data[StringConstants.message], CustomSnackBar.error);
      if (response != null &&
          response.data[StringConstants.status] == Status.success.name) {
        clearList(t2pOrderType, orderType);
        getOrders();
      }
    } finally {
      setButtonLoading();
    }
  }

  // --------------------------- Update Order Info ------------------------

  Future updateT2POrderWeight(String orderId, String weight) async {
    try {
      setUpdateButtonLoading();
      update();
      var data = {"id": orderId, "weight": weight};

      var response = await _apiService.post(
          userController.userType == UserType.delivery_partner.name
              ? URIConstants.updatePickupOrderWeight
              : URIConstants.updateDeliveryOrderWeight,
          data);

      CustomSnackBar.showSnackBar(CustomSnackBar.error,
          response?.data[StringConstants.message], CustomSnackBar.error);
      if (response != null &&
          response.data[StringConstants.status] == Status.success.name) {
        clearList(t2pOrderType, orderType);
        getOrders();
      }
      update();
    } finally {
      setUpdateButtonLoading();
      update();
    }
  }

  Future updateAF2APOrderWeight(
    String updatedProduct,
    String orderId,
  ) async {
    try {
      setDialogLoading();
      update();

      //var data = dio.FormData.fromMap({"orderId": orderId, "products": productList});

      var response =
          await _apiService.post(URIConstants.updateAF2APOrder, updatedProduct);

      CustomSnackBar.showSnackBar(CustomSnackBar.error,
          response?.data[StringConstants.message], CustomSnackBar.error);

      if (response != null &&
          response.data[StringConstants.status] == Status.success.name) {
        Get.back();
      }
      update();
    } finally {
      setDialogLoading();
      update();
    }
  }

  // ------------------------------ Boy Orders -------------------------------

  // before start order we need to check location permission and gps
  // so we continuously
  MapLocationController mapLocationController =
      Get.put(MapLocationController());

  Future checkAndAssign() async {
    if (canAssignOrStart()) {
      // to start t2p order
      if (t2pOrderType == T2POrderType.T2P) {
        if (orderType == OrderType.pickup) {
          await startOrder();
        }
        // in case of delivery we need location of delivery boy
        else {
          if (await mapLocationController.locationAndGpsEnabled()) {
            await startOrder();
          } else {
            CustomSnackBar.showSnackBar(
                CustomSnackBar.error,
                "Make sure location permission is granted and GPS is enabled.",
                CustomSnackBar.error);
          }
        }
      }

      // to start af2ap orders
      else {
        if (await mapLocationController.locationAndGpsEnabled()) {
          await startOrderAF2AP();
        } else {
          CustomSnackBar.showSnackBar(
              CustomSnackBar.error,
              "Make sure location permission is granted and GPS is enabled.",
              CustomSnackBar.error);
        }
      }
    } else {
      CustomSnackBar.showSnackBar(
          CustomSnackBar.error, "Select order.", CustomSnackBar.error);
    }
  }

  TextEditingController otpController = TextEditingController();

  Future startOrder() async {
    setButtonLoading();
    try {
      var data = {"id": orderToBeAssign[0].toString()};
      var path = URIConstants.pickupOrderStart;

      // need to send user id of boy in t2p delivery orders
      if (orderType == OrderType.deliver) {
        data["user_id"] = userController.userId;
        path = URIConstants.deliveryOrderStart;
      }

      var response = await _apiService.post(path, data);
      CustomSnackBar.showSnackBar(CustomSnackBar.error,
          response?.data[StringConstants.message], CustomSnackBar.error);

      if (response != null &&
          response.data[StringConstants.status] == Status.success.name) {
        // check if any t2p delivery order is already started or not,
        // if not then start this order and save it
        if (orderType == OrderType.deliver) {
          if (!userController.orderAlreadyStarted) {
            var order = getExactOrderByOrderId(orderToBeAssign[0]);

            // get boy current location after he start his t2p delivery order
            var currentPosition =
                await mapLocationController.getCurrentLocation();
            userController.saveStartedOrderInfo(
                order, currentPosition, t2pOrderType, orderType);

            await sendOTPToCustomer(order.id!);
          }
        }
      }
    } finally {
      setButtonLoading();
    }
  }

  Future startOrderAF2AP() async {
    setButtonLoading();
    try {
      var data = {"id": orderToBeAssign[0].toString()};
      var path = URIConstants.pickupOrderStartAF2AP;

      if (orderType == OrderType.deliver) {
        path = URIConstants.deliveryOrderStartAF2AP;
      }

      var response = await _apiService.post(path, data);
      CustomSnackBar.showSnackBar(CustomSnackBar.error,
          response?.data[StringConstants.message], CustomSnackBar.error);

      if (response != null &&
          response.data[StringConstants.status] == Status.success.name) {
        var order = getExactOrderByOrderId(orderToBeAssign[0]);
        if (orderType == OrderType.pickup) {
          // if (!userController.orderAlreadyStarted) {
          // get boy current location after he start his order
          var currentPosition =
              await mapLocationController.getCurrentLocation();
          userController.saveStartedOrderInfo(
              order, currentPosition, t2pOrderType, orderType);
          // }
        }
        await sendOTPToCustomerAF2AP();
      }
    } finally {
      setButtonLoading();
    }
  }

  // --------------------------- order delivered ----------------------------

  Future orderDelivered() async {
    setButtonLoading();

    try {
      var path = URIConstants.deliveredToCargo;
      var data = {
        "id": orderType == OrderType.pickup
            ? orderToBeAssign[0].toString()
            : userController.orderId!,
        "otp": otpController.text.toString(),
        "gateway": getPaymentType(),
      };

      if (orderType == OrderType.deliver) {
        // after order delivered we need to send total distance that delivery boy
        var distance = await mapLocationController.getDistanceByRoad(
            userController.pickupLat ?? 0.0,
            userController.pickupLng ?? 0.0,
            userController.deliveryLat ?? 0.0,
            userController.deliveryLng ?? 0.0);
        data["distance"] = distance;
        path = URIConstants.deliveredToCustomer;
      }

      var response = await _apiService.post(path, data);

      CustomSnackBar.showSnackBar(CustomSnackBar.error,
          response?.data[StringConstants.message], CustomSnackBar.error);

      if (response != null &&
          response.data[StringConstants.status] == Status.success.name) {
        // update delivery boy distance of delivery order only
        if (orderType == OrderType.deliver) {
          await updateDeliveryDistance();
          userController.clearOrderInfo();
        }
        clearList(t2pOrderType, orderType);
        getOrders();
      }
    } finally {
      setButtonLoading();
    }
  }

  Future orderDeliveredAF2AP() async {
    setButtonLoading();

    try {
      var path = URIConstants.deliveredToCustomerAF2AP;
      var data = {
        "id": orderType == OrderType.deliver
            ? orderToBeAssign[0].toString()
            : userController.orderId!,
        /* "otp": otpController.text.toString(),
        "gateway": getPaymentType(),*/
      };

      var response = await _apiService.post(path, data);

      CustomSnackBar.showSnackBar(CustomSnackBar.error,
          response?.data[StringConstants.message], CustomSnackBar.error);

      if (response != null &&
          response.data[StringConstants.status] == Status.success.name) {
        if (orderType == OrderType.pickup) {
          userController.clearOrderInfo();
        }
        clearList(t2pOrderType, orderType);
        getOrders();
      }
    } finally {
      setButtonLoading();
    }
  }

  Future updateDeliveryDistance() async {
    try {
      var distance = await mapLocationController.getDistanceByRoad(
          userController.pickupLat ?? 0.0,
          userController.pickupLng ?? 0.0,
          userController.deliveryLat ?? 0.0,
          userController.deliveryLng ?? 0.0);
      var data = {
        "id": orderToBeAssign[0].toString(),
        "delivery_distance": distance
      };

      var response =
          await _apiService.post(URIConstants.updateDeliveryDistance, data);
    } finally {}
  }

  // ----------------------- Get Info --------------------------

  String getPaymentType() {
    var userPaymentInfo = "";
    if (t2pOrderType == T2POrderType.T2P) {
      if (orderType == OrderType.pickup) {
        userPaymentInfo =
            getExactOrderByOrderId(orderToBeAssign[0]).paymentMode ?? "";
      } else {
        // when user pay cash on delivery
        if (userController.paymentMode == PaymentType.COD.name) {
          if (paymentType == PaymentType.COD) {
            userPaymentInfo = "cod";
          } else if (paymentType == PaymentType.Link) {
            userPaymentInfo = "online";
          } else {
            userPaymentInfo = "PhonePe";
          }
        } else {
          userPaymentInfo = userController.paymentMode ?? "";
        }
      }
    }
    return userPaymentInfo;
  }

  CommonOrder getExactOrderByOrderId(String orderId) {
    CommonOrder? order;
    if (t2pOrderType == T2POrderType.T2P) {
      //t2p pickup orders
      if (orderType == OrderType.pickup) {
        for (var order in t2pPickupFilterOrders) {
          if (order.id == orderId) {
            return order;
          } else {
            return t2pPickupFilterOrders[0];
          }
        }
      }

      //t2p delivery orders
      else {
        for (var order in t2pDeliveryFilterOrders) {
          if (order.id == orderId) {
            //paymentGateway = order.paymentMode;
            return order;
          } else {
            return t2pDeliveryFilterOrders[0];
          }
        }
      }
    } else {
      // af2ap pickup order
      if (orderType == OrderType.pickup) {
        for (var order in aF2APPickupFilterOrders) {
          if (order.id == orderId) {
            //paymentGateway = order.paymentMode;
            return order;
          } else {
            return aF2APPickupFilterOrders[0];
          }
        }
      }
      //af2ap delivery orders
      else {
        for (var order in aF2APDeliveryFilterOrders) {
          if (order.id == orderId) {
            //paymentGateway = order.paymentMode;
            return order;
          } else {
            return aF2APDeliveryFilterOrders[0];
          }
        }
      }
    }
    return order!;
  }

  // ------------------- OTP Send ------------------------------------------
  Future sendOTPToCargo() async {
    setDialogLoading();
    try {
      var data = {
        "id": orderToBeAssign[0].toString(),
      };

      var response = await _apiService.post(URIConstants.sendOTPToCargo, data);
      CustomSnackBar.showSnackBar(CustomSnackBar.error,
          response?.data[StringConstants.message], CustomSnackBar.error);
    } finally {
      setDialogLoading();
    }
  }

  Future sendOTPToCustomer(String mobile) async {
    setDialogLoading();
    try {
      var data = {
        "id": mobile,
      };

      var response =
          await _apiService.post(URIConstants.sendOTPToCustomer, data);
      CustomSnackBar.showSnackBar(CustomSnackBar.error,
          response?.data[StringConstants.message], CustomSnackBar.error);
    } finally {
      setDialogLoading();
    }
  }

  Future sendOTPToCustomerAF2AP() async {
    setDialogLoading();
    try {
      var orderId = "";
      if (orderType == OrderType.deliver) {
        orderId = orderToBeAssign[0];
      } else {
        orderId = userController.orderId!;
      }
      var data = {
        "id": orderId,
      };

      var response =
          await _apiService.post(URIConstants.sendOTPToCustomerAF2AP, data);
      CustomSnackBar.showSnackBar(CustomSnackBar.error,
          response?.data[StringConstants.message], CustomSnackBar.error);
    } finally {
      setDialogLoading();
    }
  }

  // ---------------------- generate qr code --------------------------------
  generateQRCode() async {
    setDialogLoading();
    String rawdata = getBase64(payloadData());
    String xVerifyHeader = getHeaderXverify(rawdata);
    await getQR(xVerifyHeader, rawdata);
    update();
  }

  String getBase64(String payload) {
    return base64.encode(utf8.encode(payload));
  }

  String getHeaderXverify(String dataString64) {
    String xVerifyContent =
        '$dataString64/v3/qr/init${StringConstants.saltkey}';
    Digest digest = sha256.convert(utf8.encode(xVerifyContent));
    String checksum = '$digest###${StringConstants.saltIndex}';
    return checksum;
  }

  String getHeaderXverifyForStatus() {
    // todo : getting error in header and the error is : Invalid x-verify header
    String xVerifyContent =
        '/v3/transaction/${StringConstants.merchantId}/$txnId/status${StringConstants.saltkey}';

    Digest digest = sha256.convert(utf8.encode(xVerifyContent));

    StringBuffer hexString = StringBuffer();
    for (int i = 0; i < digest.bytes.length; i++) {
      String hex = digest.bytes[i].toRadixString(16);
      if (hex.length == 1) hexString.write('0');
      hexString.write(hex);
    }

    String checksum = '${hexString.toString()}###${StringConstants.saltIndex}';
    return checksum;
  }

  String payloadData() {
    var price = userController.orderPrice;
    double priceFloat = double.parse(price!);
    int priceLong = (priceFloat.toInt()) * 100;

    // Creating Transaction Id
    Random rand = Random();
    String randomString =
        "${rand.nextInt(1)}${DateTime.now().millisecondsSinceEpoch ~/ 1000}";
    txnId = "TXNT2P${randomString.substring(1, 10)}";

    Map<String, dynamic> params = {
      'merchantId': StringConstants.merchantId,
      'transactionId': txnId,
      'merchantOrderId': 'ORD${randomString.substring(1, 10)}',
      'amount': priceLong,
      'expiresIn': 360,
      'storeId': 'storeIdt2p',
      'terminalId': 'terminalidt2p',
    };

    String payload = jsonEncode(params);
    return payload;
  }

  Future<void> getQR(String xVerifyHeader, String rawdata) async {
    String baseUrl = "${URIConstants.phonePeBaseURI}${URIConstants.getQr}";

    try {
      var response = await _apiService.post(baseUrl, {"request": rawdata},
          additionalHeaders: {'X-VERIFY': xVerifyHeader}, customBaseURI: true);

      if (response?.statusCode == 200) {
        var qrResponse = response?.data;
        qrAvailable.value = qrResponse['data']['qrString'];
        printValue("Qr response : $qrResponse");
      } else {
        // Handle error cases
        printValue('Server Error: ${response?.statusCode}');
      }
    } catch (e) {
      printValue('Exception: $e');
    } finally {
      setDialogLoading();
    }
  }

  Future checkPaymentStatus() async {
    setDialogLoading();
    try {
      var path =
          "${URIConstants.phonePeBaseURI}v3/transaction/${StringConstants.merchantId}/$txnId/status";
      var xVerify = getHeaderXverifyForStatus();
      var headers = {"X-VERIFY": xVerify};
      var response = await _apiService.get(path,
          additionalHeaders: headers, customBaseURI: true);

      CustomSnackBar.showSnackBar(CustomSnackBar.error,
          response?.data?['message'], CustomSnackBar.error);

      if (response != null &&
          response.data!['code'] == PhonePePaymentStatus.PAYMENT_SUCCESS.name) {
        Get.back();
        phonePePaymentSuccess.value = true;
      }
    } finally {
      setDialogLoading();
    }
  }

  Future cancelPayment() async {
    setDialogLoading();
    try {
      var path =
          "${URIConstants.phonePeBaseURI}v3/charge/${StringConstants.merchantId}/$txnId/cancel";
      var xVerify = getHeaderXverifyForCancel();
      var headers = {"Content-Type": "application/json", "X-VERIFY": xVerify};

      var response = await _apiService.post(path, {},
          additionalHeaders: headers, customBaseURI: true);

      CustomSnackBar.showSnackBar(CustomSnackBar.error,
          response?.data?['message'], CustomSnackBar.error);

      if (response != null &&
          response.data!['code'] == Status.success.name.toUpperCase()) {
        // close cod dialog
        Get.back();
      }
    } finally {
      setDialogLoading();
    }
  }

  String getHeaderXverifyForCancel() {
    String xVerifyContent =
        '/v3/charge/${StringConstants.merchantId}/$txnId/cancel${StringConstants.saltkey}';

    Digest digest =
        sha256.convert(Uint8List.fromList(utf8.encode(xVerifyContent)));

    String checksum = '${digest.toString()}###${StringConstants.saltIndex}';
    return checksum;
  }

// ----------------------- Ghar ka khana boy-----------------------
}
