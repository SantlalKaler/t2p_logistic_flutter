import 'package:get/get.dart';
import 'package:t2p_logistic/data/api_services.dart';
import 'package:t2p_logistic/data/status.dart';
import 'package:t2p_logistic/domain/Model/AF2APOrderResponse.dart';
import 'package:t2p_logistic/domain/Model/T2POrderResponse.dart';
import 'package:t2p_logistic/domain/enums/user_type.dart';
import 'package:t2p_logistic/domain/mapper/order_mapper.dart';
import 'package:t2p_logistic/presentation/controllers/user_controller.dart';
import 'package:t2p_logistic/presentation/theme/resource/strings_constants.dart';
import 'package:t2p_logistic/presentation/theme/resource/uri_constants.dart';
import 'package:t2p_logistic/presentation/widgets/custom_snackbar.dart';

import '../../theme/resource/custom_constants.dart';

ApiService _apiService = ApiService();

class OrderController extends GetxController {
  RxBool pickupLoading = false.obs;
  RxBool deliveryLoading = false.obs;
  RxBool buttonLoading = false.obs;
  RxBool updateButtonLoading = false.obs;
  RxBool selectAllOrders = false.obs;

  UserController userController = Get.find();
  RxBool gharKaKhanaCheck = false.obs;
  RxList<CommonOrder> t2pPickupOrders = RxList<CommonOrder>();
  RxList<CommonOrder> t2pDeliveryOrders = RxList<CommonOrder>();
  RxList<CommonOrder> aF2APPickupOrders = RxList<CommonOrder>();
  RxList<CommonOrder> aF2APDeliveryOrders = RxList<CommonOrder>();
  RxList<String> orderIds = RxList<String>();
  RxList<String> t2pPickupSelectedOrderIds = RxList<String>();
  RxList<String> t2pDeliverSelectedOrderIds = RxList<String>();
  RxList<String> aF2APDeliverSelectedOrderIds = RxList<String>();
  RxList<String> aF2APPickupSelectedOrderIds = RxList<String>();

  T2POrderType t2pOrderType = T2POrderType.T2P;
  OrderType orderType = OrderType.pickup;

  setPickupLoading() => pickupLoading.value = !pickupLoading.value;

  setDeliveryLoading() => deliveryLoading.value = !deliveryLoading.value;

  setButtonLoading() => buttonLoading.value = !buttonLoading.value;
  setUpdateButtonLoading() => updateButtonLoading.value = !updateButtonLoading.value;

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
          t2pPickupOrders.length == t2pPickupSelectedOrderIds.length) {
        selected = true;
      } else if (orderType == OrderType.deliver &&
          t2pDeliveryOrders.length == t2pDeliverSelectedOrderIds.length) {
        selected = true;
      }
    } else {
      if (orderType == OrderType.pickup &&
          aF2APPickupOrders.length == aF2APPickupSelectedOrderIds.length) {
        selected = true;
      } else if (orderType == OrderType.deliver &&
          aF2APDeliveryOrders.length == aF2APDeliverSelectedOrderIds.length) {
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
          for (var order in t2pPickupOrders) {
            t2pPickupSelectedOrderIds.add(order.id);
          }
        }
      } else {
        t2pDeliverSelectedOrderIds.clear();
        if (selectAll) {
          for (var order in t2pDeliveryOrders) {
            selectOrder(order.id);
          }
        }
      }
    } else {
      if (orderType == OrderType.pickup) {
        aF2APPickupSelectedOrderIds.clear();
        if (selectAll) {
          for (var order in aF2APPickupOrders) {
            aF2APPickupSelectedOrderIds.add(order.id);
          }
        }
      } else {
        aF2APDeliverSelectedOrderIds.clear();
        if (selectAll) {
          for (var order in aF2APDeliveryOrders) {
            selectOrder(order.id);
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
        if (orderType == OrderType.pickup && t2pPickupOrders.isEmpty) {
          getT2POrders();
        } else if (orderType == OrderType.deliver &&
            t2pDeliveryOrders.isEmpty) {
          getT2POrders(orderType: OrderType.deliver);
        }
        break;
      case T2POrderType.AF2AP:
        if (orderType == OrderType.pickup && aF2APPickupOrders.isEmpty) {
          getAF2APOrders();
        } else if (orderType == OrderType.deliver &&
            aF2APDeliveryOrders.isEmpty) {
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
    } else {}

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

      //dummy changes
      // var data = {"id": userController.userId};
      var userId = userController.userId;
      if (orderType == OrderType.pickup) {
        userId = "65bdd1f3c919f5489792bdea";
      } else {
        userId = "626e856c90a1f86b6a92d4f6";
      }
      var data = {"id": userId};

      var response = await _apiService.post(path, data);

      if (response != null && response.data['status'] == Status.success.name) {
        //clear order list
        clearList(t2pOrderType, orderType);

        T2pOrderResponse t2pOrderResponse =
            T2pOrderResponse.fromJson(response.data);
        if (t2pOrderResponse.order!.isNotEmpty) {
          for (var order in t2pOrderResponse.order!) {
            var orderAfterConvert = order.toCommonOrder();
            if (orderAfterConvert != null) {
              if (orderType == OrderType.pickup) {
                t2pPickupOrders.add(orderAfterConvert);
              } else {
                t2pDeliveryOrders.add(orderAfterConvert);
              }
            }
          }
        }
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
    if (t2pOrderType == T2POrderType.T2P) {
      if (orderType == OrderType.pickup) {
        t2pPickupOrders.clear();
      } else {
        t2pDeliveryOrders.clear();
      }
    }
    // AF2AP
    else {
      if (orderType == OrderType.pickup) {
        aF2APPickupOrders.clear();
      } else {
        aF2APDeliveryOrders.clear();
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
      var userId = userController.userId;
      var data = {
        "id": userId /*, "limit": 50, "page": 1*/
      };

      var response = await _apiService.post(path, {}, hasQueryParam: true, queryParam: data);
      if (response != null) {
        Af2apOrderResponse af2apOrderResponse =
            Af2apOrderResponse.fromJson(response.data);

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
                aF2APPickupOrders.add(orderAfterConvert);
              } else {
                aF2APDeliveryOrders.add(orderAfterConvert);
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

  // ------------------------------- Assign Order -------------------------------
  RxList<String> orderToBeAssign = RxList<String>();

  bool partnerCanAssign() {
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

  Future assignOrder(String boy) async {
    setButtonLoading();
    try {
      // list to string
      var orderIds = orderToBeAssign.length > 1
          ? orderToBeAssign.join(",")
          : orderToBeAssign.first;

      // parameters
      Map<String, String> data = {"id": orderIds};
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

  Future updatePickupOrderWeight(String orderId, String weight) async {
    try {
      setUpdateButtonLoading();
      update();
      var data = {"id": orderId, "weight": weight};

      var response = await _apiService.post(URIConstants.updatePickupOrderWeight, data);

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
}
