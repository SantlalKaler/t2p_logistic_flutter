import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:t2p_logistic/domain/Model/AF2APOrderResponse.dart';
import 'package:t2p_logistic/domain/enums/add_edit_delivery_boy.dart';
import 'package:t2p_logistic/domain/enums/user_type.dart';
import 'package:t2p_logistic/presentation/controllers/user_controller.dart';
import 'package:t2p_logistic/presentation/dialogs/default_dialog.dart';
import 'package:t2p_logistic/presentation/screens/partners/boy/add_delivery_boy.dart';
import 'package:t2p_logistic/presentation/widgets/custom_snackbar.dart';

import '../../dialogs/cod_dialog.dart';
import '../../dialogs/otp_dialog.dart';
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
          return Container(
            padding:
                EdgeInsets.symmetric(horizontal: DimensConstants.screePadding),
            child: Obx(() => userController.userType ==
                    UserType.delivery_partner.name
                ?
                // partner buttons
                Row(
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Expanded(
                          child: ElevatedButton(
                        onPressed: () {
                          if (controller.buttonLoading.isFalse) {
                            if (controller.canAssignOrStart()) {
                              deliveryBoyController.getListLogisticBoy();
                              showModalBottomSheet(
                                context: context,
                                builder: (context) {
                                  return deliveryBoyList();
                                },
                              );
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
                      Expanded(
                          child: ElevatedButton(
                              onPressed: () {
                                if (controller.buttonLoading.isFalse) {
                                  if (controller.canAssignOrStart()) {
                                    showDialog(
                                      context: context,
                                      builder: (context) {
                                        return DefaultDialog(
                                          message:
                                              "Would you like to mark as delivered this order?",
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
                                  controller.orderType == OrderType.deliver && userController.orderAlreadyStarted) ||
                              (controller.t2pOrderType == T2POrderType.AF2AP && controller.orderType ==
                                          OrderType.pickup&& userController.orderAlreadyStarted)
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
                                  if (controller.canAssignOrStart()) {
                                    // in these 2 cases boy have to first start order then only he can end order
                                    // 1. T2P delivery order
                                    // 2. AF2AP pickup order
                                    if (
                                    (controller.t2pOrderType == T2POrderType.T2P && controller.orderType == OrderType.deliver)||
                                    (controller.t2pOrderType == T2POrderType.AF2AP && controller.orderType == OrderType.pickup)
                                        && !userController.orderAlreadyStarted) {
                                      CustomSnackBar.showSnackBar(
                                          CustomSnackBar.error,
                                          "First start order.",
                                          CustomSnackBar.error);
                                    } else {
                                      showDialog(
                                        context: context,
                                        builder: (context) {
                                          // in these 2 cases we need to take payment from user so we show cod dialog otherwise cod dialog
                                          // 1. T2P delivery
                                          // 2. AF2AP pickup
                                          return (controller.t2pOrderType == T2POrderType.T2P
                                              && controller.orderType == OrderType.deliver
                                              && userController.paymentMode == PaymentType.COD.name)
                                              || (controller.t2pOrderType == T2POrderType.AF2AP
                                                  && controller.orderType == OrderType.pickup
                                                  && userController.paymentMode == PaymentType.COD.name)
                                              ? const CODDialog()
                                              : const OTPDialog();
                                        },
                                      );
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

deliveryBoyList() {
  OrderController controller = Get.find();
  return GetBuilder(
      init: DeliveryBoyController(),
      builder: (dController) {
        return Scaffold(
          floatingActionButton: FloatingActionButton.small(
            onPressed: () {
              Get.to(() => const AddDeliveryBoy(
                    addEditDeliveryBoy: AddEditDeliveryBoy.add,
                  ));
            },
            child: const Icon(Icons.add),
          ),
          body: Padding(
            padding: EdgeInsets.all(DimensConstants.screePadding),
            child: dController.isLoading.isTrue
                ? Center(child: circularloadingRedSmall())
                : dController.boyList.isEmpty
                    ? const AppEmptyView(
                        message: "No User Found.",
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
