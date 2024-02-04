import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:t2p_logistic/domain/enums/add_edit_delivery_boy.dart';
import 'package:t2p_logistic/presentation/dialogs/default_dialog.dart';
import 'package:t2p_logistic/presentation/screens/partners/boy/add_delivery_boy.dart';
import 'package:t2p_logistic/presentation/widgets/custom_snackbar.dart';

import '../../theme/resource/dimens.dart';
import '../../widgets/app_empty_view.dart';
import '../../widgets/circular_loadings.dart';
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

  @override
  Widget build(BuildContext context) {
    return GetBuilder(
        init: OrderController(),
        builder: (controller) {
          return Container(
            padding:
                EdgeInsets.symmetric(horizontal: DimensConstants.screePadding),
            child: Obx(() => Row(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Expanded(
                        child: ElevatedButton(
                      onPressed: () {
                        if (controller.buttonLoading.isFalse) {
                          if (controller.partnerCanAssign()) {
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
                                if (controller.partnerCanAssign()) {
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
