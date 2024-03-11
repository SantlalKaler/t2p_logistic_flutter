import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:t2p_logistic/domain/enums/add_edit_delivery_boy.dart';
import 'package:t2p_logistic/domain/enums/other.dart';
import 'package:t2p_logistic/presentation/controllers/user_controller.dart';
import 'package:t2p_logistic/presentation/dialogs/default_dialog.dart';
import 'package:t2p_logistic/presentation/screens/partners/boy/add_delivery_boy.dart';
import 'package:t2p_logistic/presentation/widgets/custom_snackbar.dart';

import '../../dialogs/cod_dialog.dart';
import '../../dialogs/otp_dialog.dart';
import '../../theme/resource/custom_constants.dart';
import '../../theme/resource/dimens.dart';
import '../../widgets/app_empty_view.dart';
import '../../widgets/circular_loadings.dart';
import '../address/map_location_controller.dart';
import '../partners/boy/DeliveryBoyController.dart';
import '../partners/boy/manage_delivery_boy.dart';
import 'order_controller.dart';

class OrderBottomSheet extends StatefulWidget {
  const OrderBottomSheet({super.key});

  @override
  State<OrderBottomSheet> createState() => _OrderBottomSheetState();
}

class _OrderBottomSheetState extends State<OrderBottomSheet> {
  DeliveryBoyController deliveryBoyController = Get.find();
  UserController userController = Get.find();
  MapLocationController mapLocationController = Get.find();

  @override
  Widget build(BuildContext context) {
    return GetBuilder(
        init: OrderController(),
        builder: (controller) {
          return /*(userController.userType == UserType.lp_manager.name ||
              userController.userType == UserType.lp_head.name)
              ? const SizedBox.shrink()
              : */
              Container(
            padding:
                EdgeInsets.symmetric(horizontal: DimensConstants.screePadding),
            child: Obx(() => (userController.userType ==
                        UserType.delivery_partner.name ||
                    userController.userType == UserType.lp_manager.name ||
                    userController.userType == UserType.lp_head.name)
                ?
                // delivery partner, lp manager, lp head buttons
                Row(
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Expanded(
                          child: ElevatedButton(
                        onPressed: () {
                          if (controller.buttonLoading.isFalse) {
                            if (controller.anyOrderSelected()) {
                              // in case of delivery partner we only need delivery boy
                              if (userController.userType ==
                                  UserType.delivery_partner.name) {
                                deliveryBoyController.getListLogisticBoy();
                                showModalBottomSheet(
                                  context: context,
                                  builder: (context) {
                                    return deliveryBoyList();
                                  },
                                );
                              }

                              /*but in case of lp manager and lp head ->
                              lp manager -> first manager have to select delivery partner
                              then he can see delivery boy list of that delivery partner
                              after that lp manager can assign
                              lp head -> first select lp manager then delivery partner then
                              delivery boy after that lp head can assign order
                              */
                              if (userController.userType ==
                                      UserType.lp_manager.name ||
                                  userController.userType ==
                                      UserType.lp_head.name) {
                                if (controller.selectedPartner == null) {
                                  CustomSnackBar.showSnackBar(
                                      CustomSnackBar.error,
                                      "Please select any delivery partner.",
                                      CustomSnackBar.error);
                                } else {
                                  deliveryBoyController.getListLogisticBoy(
                                      lpManagerId: controller.getPartnerId());
                                  showModalBottomSheet(
                                    context: context,
                                    builder: (context) {
                                      return deliveryBoyList();
                                    },
                                  );
                                }
                              }
                            } else {
                              CustomSnackBar.showSnackBar(CustomSnackBar.error,
                                  "Select order.", CustomSnackBar.error);
                            }
                          }
                        },
                        child: controller.buttonLoading.isFalse
                            ? const Text("Assign Order")
                            : circularloadingWhiteSmall(),
                      )),
                      Gap(DimensConstants.spaceBetweenViews),

                      // this button shows only for delivery partner, delivery orders(T2P and AF2AP both)
                      if ((userController.userType ==
                                  UserType.delivery_partner.name ||
                              userController.userType ==
                                  UserType.lp_manager.name ||
                              userController.userType ==
                                  UserType.lp_head.name) &&
                          controller.orderType == OrderType.deliver)
                        Expanded(
                            child: ElevatedButton(
                                onPressed: () {
                                  if (controller.buttonLoading.isFalse) {
                                    if (controller.anyOrderSelected()) {
                                      if (userController.userType ==
                                          UserType.delivery_partner.name) {
                                        markDelivered(context);
                                      }

                                      // if lp manager is logged in then he need to select any delivery
                                      // partner to mark as delivered any order
                                      // that's why I check if any delivery partner is selected or not
                                      if ((userController.userType ==
                                                  UserType.lp_manager.name ||
                                              userController.userType ==
                                                  UserType.lp_head.name) &&
                                          controller.selectedPartner == null) {
                                        CustomSnackBar.showSnackBar(
                                            CustomSnackBar.error,
                                            "Please Select delivery partner.",
                                            CustomSnackBar.error);
                                      } else {
                                        markDelivered(context);
                                      }
                                    } else {
                                      CustomSnackBar.showSnackBar(
                                          CustomSnackBar.error,
                                          "Select order.",
                                          CustomSnackBar.error);
                                    }
                                  }
                                },
                                child: controller.buttonLoading.isTrue
                                    ? circularloadingWhiteSmall()
                                    : const Text("Mark Delivered"))),
                    ],
                  )
                :
                // boy buttons
                Row(
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      // if t2p delivery order already started then show view map button else start order
                      (controller.t2pOrderType == T2POrderType.T2P &&
                                  controller.orderType == OrderType.deliver &&
                                  userController.orderAlreadyStarted) ||
                              (controller.t2pOrderType == T2POrderType.AF2AP &&
                                  controller.orderType == OrderType.pickup &&
                                  userController.orderAlreadyStarted)
                          ? Expanded(
                              child: ElevatedButton(
                              onPressed: () async {
                                mapLocationController.openGoogleMap(
                                    userController.deliveryLat!,
                                    userController.deliveryLng!);
                              },
                              child: const Text("View Map"),
                            ))
                          : Expanded(
                              child: ElevatedButton(
                              onPressed: () async {
                                if (controller.buttonLoading.isFalse) {
                                  if (userController.orderAlreadyStarted) {
                                    CustomSnackBar.showSnackBar(
                                        CustomSnackBar.error,
                                        "Already ${userController.t2pOrderType}[${userController.orderId}] order is started, Please end that order first.",
                                        CustomSnackBar.error);
                                  } else {
                                    controller.checkAndAssign();
                                  }
                                }
                              },
                              child: controller.buttonLoading.isFalse
                                  ? const Text("Start Order")
                                  : circularloadingWhiteSmall(),
                            )),
                      Gap(DimensConstants.spaceBetweenViews),
                      Expanded(
                          child: ElevatedButton(
                              onPressed: () {
                                if (controller.buttonLoading.isFalse) {
                                  if (controller.anyOrderSelected()) {
                                    // in these 2 cases boy have to first start order then only he can end order
                                    // 1. T2P delivery order
                                    // 2. AF2AP pickup order
                                    if (((controller.t2pOrderType ==
                                                    T2POrderType.T2P &&
                                                controller.orderType ==
                                                    OrderType.deliver) ||
                                            (controller.t2pOrderType ==
                                                    T2POrderType.AF2AP &&
                                                controller.orderType ==
                                                    OrderType.pickup)) &&
                                        (!userController.orderAlreadyStarted)) {
                                      printValue(
                                          "Order already started : ${userController.orderAlreadyStarted}\n"
                                          "${(controller.t2pOrderType == T2POrderType.T2P && controller.orderType == OrderType.deliver)}\n"
                                          "${(controller.t2pOrderType == T2POrderType.AF2AP && controller.orderType == OrderType.pickup)}");
                                      CustomSnackBar.showSnackBar(
                                          CustomSnackBar.error,
                                          "First start order.",
                                          CustomSnackBar.error);
                                    } else {
                                      takePayment(context);
                                    }
                                  } else {
                                    CustomSnackBar.showSnackBar(
                                        CustomSnackBar.error,
                                        "Select order.",
                                        CustomSnackBar.error);
                                  }
                                }
                              },
                              child: controller.buttonLoading.isTrue
                                  ? circularloadingWhiteSmall()
                                  : const Text("End Order"))),
                    ],
                  )),
          );
        });
  }
}

markDelivered(BuildContext context) {
  OrderController controller = Get.find();
  showDialog(
    context: context,
    builder: (context) {
      return DefaultDialog(
        message: "Would you like to mark as delivered this order?",
        btn1Txt: "Yes",
        btn1Click: () {
          // close dialog
          Get.back();
          //api call
          controller.markAsDelivered();
        },
        btn2Txt: "No",
        btn2Click: () {
          Get.back();
        },
      );
    },
  );
}

takePayment(BuildContext context) {
  OrderController controller = Get.find();
  UserController userController = Get.find();
  showDialog(
    context: context,
    builder: (context) {
      // in these 2 cases we need to take payment from user so we show cod dialog otherwise cod dialog
      // 1. T2P delivery
      // 2. AF2AP pickup
      printValue("Order payment mode is ${userController.paymentMode}");
      return (controller.t2pOrderType == T2POrderType.T2P &&
                  controller.orderType == OrderType.deliver &&
                  userController.paymentMode == PaymentType.COD.name) ||
              (controller.t2pOrderType == T2POrderType.AF2AP &&
                  controller.orderType == OrderType.pickup &&
                  userController.paymentMode == PaymentType.COD.name)
          ? const CODDialog()
          : const OTPDialog();
    },
  );
}

deliveryBoyList() {
  OrderController controller = Get.find();
  UserController userController = Get.find();
  return GetBuilder(
      init: DeliveryBoyController(),
      builder: (dController) {
        return Scaffold(
          floatingActionButton:
              userController.userType == UserType.delivery_partner.name
                  ? FloatingActionButton.small(
                      onPressed: () {
                        Get.to(() => const AddUser(
                              addEditDeliveryBoy: AddEditDeliveryBoy.add,
                            ));
                      },
                      child: const Icon(Icons.add),
                    )
                  : const SizedBox.shrink(),
          body: Padding(
            padding: EdgeInsets.all(DimensConstants.screePadding),
            child: dController.isLoading.isTrue
                ? Center(child: circularloadingRedSmall())
                : dController.boyList.isEmpty
                    ? const AppEmptyView(
                        message: "No Delivery Boy Found.",
                      )
                    : ListView.separated(
                        itemBuilder: (context, index) {
                          return InkWell(
                            onTap: () {
                              showDialog(
                                context: context,
                                builder: (context) {
                                  return DefaultDialog(
                                    message:
                                        "Would you like to assign this order?",
                                    btn1Txt: "Yes",
                                    btn1Click: () {
                                      // close dialog
                                      Get.back();
                                      //close bottom sheet
                                      Get.back();
                                      //api call
                                      controller.assignOrder(
                                          dController.boyList[index].id!);
                                    },
                                    btn2Txt: "No",
                                    btn2Click: () {
                                      Get.back();
                                    },
                                  );
                                },
                              );
                            },
                            child: singleUserItem(dController.boyList[index],
                                onStatusChange: (userId) {
                              dController.userStatusChange(userId);
                            }, showSwitchButton: false),
                          );
                        },
                        separatorBuilder: (context, index) {
                          return SizedBox(
                            height: DimensConstants.spaceBetweenViews,
                          );
                        },
                        itemCount: dController.boyList.length),
          ),
        );
      });
}
