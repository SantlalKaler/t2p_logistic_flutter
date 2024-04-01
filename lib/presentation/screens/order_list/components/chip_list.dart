import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:t2p_logistic/presentation/controllers/user_controller.dart';
import 'package:t2p_logistic/presentation/screens/address/address_controller.dart';
import 'package:t2p_logistic/presentation/screens/order_list/order_controller.dart';
import 'package:t2p_logistic/presentation/theme/resource/custom_constants.dart';

import '../../../../domain/Model/single_filter_item.dart';
import '../../../../domain/enums/other.dart';
import '../../../theme/resource/color_constant.dart';
import '../../../theme/resource/dimens.dart';
import '../../../widgets/custom_snackbar.dart';
import '../../partners/boy/DeliveryBoyController.dart';

class ChipList extends StatefulWidget {
  const ChipList({super.key});

  @override
  State<ChipList> createState() => _ChipListState();
}

class _ChipListState extends State<ChipList> {
  OrderController controller = Get.find();
  UserController userController = Get.find();
  DeliveryBoyController deliveryBoyController = Get.find();

  @override
  Widget build(BuildContext context) {
    return GetBuilder(
        init: OrderController(),
        builder: (controller) {
          return Container(
            width: double.infinity,
            color: ColorConstants.screenBackgroundColor,
            child: ListView.separated(
                shrinkWrap: true,
                scrollDirection: Axis.horizontal,
                itemBuilder: (context, index) {
                  var item = controller.getChipList()[index];
                  return Chip(
                      backgroundColor: Colors.white,
                      //  elevation: 1,
                      deleteIcon: const Icon(
                        Icons.arrow_drop_down,
                        color: Colors.red,
                      ),
                      onDeleted: () {
                        switch (item.id) {
                          case FilterItemId.orderType:
                            showT2POrderTypes();
                            break;
                          case FilterItemId.dateRange:
                          // TODO: Handle this case.
                          case FilterItemId.pickupBoy:
                          // TODO: Handle this case.
                          case FilterItemId.print:
                            showPrintView();
                            break;
                          case FilterItemId.city:
                            showCities();
                            break;
                          case FilterItemId.status:
                            if (controller.anyOrderSelected()) {
                              showStatus();
                            } else {
                              CustomSnackBar.showSnackBar(CustomSnackBar.error,
                                  "Select Order", CustomSnackBar.error);
                            }
                            break;
                          case FilterItemId.lpManager:
                            /*here user type I use to determine, by which type
                          need to filter order list
                          by lp manager or delivery partner*/
                            showManagerOrPartnerList(
                                deliveryBoyController.managerList
                                    .map((element) => element?.fullName ?? "")
                                    .toList(),
                                UserType.lp_manager);

                          case FilterItemId.deliveryPartner:
                            // if user type is lp head then if he want to filter order list
                            // according to delivery partner then he need to first select manager
                            // then he can get delivery partner list of that manger
                            if (userController.userType ==
                                    UserType.lp_head.name &&
                                controller.selectedManager == null) {
                              CustomSnackBar.showSnackBar(
                                  "", "Please select lp manager first", "");
                            } else {
                              showManagerOrPartnerList(
                                  deliveryBoyController.partnerList
                                      .map((element) => element.fullName!)
                                      .toList(),
                                  UserType.delivery_partner);
                            }
                          case FilterItemId.startDate:
                          // TODO: Handle this case.
                          case FilterItemId.endDate:
                          // TODO: Handle this case.
                        }
                      },
                      //avatar: Icon(item.icon),
                      label: Text(item.title));
                },
                separatorBuilder: (context, index) {
                  return SizedBox(
                    width: DimensConstants.spaceBetweenViewsAndSubViews,
                  );
                },
                itemCount: controller.getChipList().length),
          );
        });
  }

  showT2POrderTypes() {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: false,
      builder: (context) {
        return SizedBox(
          height: 120,
          child: Column(
            children: [
              RadioListTile(
                  value: T2POrderType.T2P.name,
                  title: Text(
                    T2POrderType.T2P.name,
                  ),
                  groupValue: controller.t2pOrderType.name,
                  onChanged: (v) {
                    if (v != null) {
                      controller.changeT2POrderType(T2POrderType.T2P);
                    }
                    Get.back();
                  }),
              RadioListTile(
                  value: T2POrderType.AF2AP.name,
                  title: Text(
                    T2POrderType.AF2AP.name,
                  ),
                  groupValue: controller.t2pOrderType.name,
                  onChanged: (v) {
                    if (v != null) {
                      controller.changeT2POrderType(T2POrderType.AF2AP);
                    }
                    Get.back();
                  })
            ],
          ),
        );
      },
    );
  }

  showManagerOrPartnerList(List<String> items, UserType userType) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: false,
      builder: (context) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            TextButton(
                onPressed: () {
                  controller.clearFilter();
                  Get.back();
                },
                child: const Text("Clear")),
            Expanded(
              child: ListView.builder(
                itemCount: items.length,
                itemBuilder: (context, index) {
                  var item = items[index];
                  return ListTile(
                      title: Text(
                        item,
                      ),
                      onTap: () {
                        controller.filterOrder(userType, item);
                        Get.back();
                      });
                },
              ),
            ),
          ],
        );
      },
    );
  }

  showStatus() {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: false,
      builder: (context) {
        var items = controller.orderType == OrderType.pickup
            ? controller.pickupOrderStatus
            : controller.deliveryOrderStatus;
        printValue("Items length : ${items.length}\n"
            "Pickup order type : ${controller.pickupOrderStatus.length}");
        return SizedBox(
            //  height: 120,
            child: ListView.builder(
          itemCount: items.length,
          itemBuilder: (context, index) {
            var item = items[index];
            return ListTile(
              title: Text(item),
              onTap: () {
                controller.getExactStatusKey(item);
                Get.back();
              },
            );
          },
        ));
      },
    );
  }

  showCities() {
    AddressController addressController = Get.find();
    return showModalBottomSheet(
      context: context,
      isScrollControlled: false,
      builder: (context) {
        var items = addressController.allCities;
        printValue("Items length : ${items.length}\n"
            "Pickup order type : ${controller.pickupOrderStatus.length}");
        return Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            TextButton(
                onPressed: () {
                  controller.clearCityFilter();
                  Get.back();
                },
                child: const Text("Clear")),
            Expanded(
              child: ListView.builder(
                itemCount: items.length,
                itemBuilder: (context, index) {
                  var item = items[index];
                  return ListTile(
                    title: Text(item.name ?? ""),
                    onTap: () {
                      controller.filterOrderByCity(item.name ?? "");
                      Get.back();
                    },
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  showPrintView() {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: false,
      builder: (context) {
        var items = [
          "Print Today Order",
          "Print Today Product",
          "Print Tomorrow Order",
          "Print Tomorrow Product",
        ];
        return SizedBox(
            height: 240,
            child: ListView.builder(
              itemCount: items.length,
              itemBuilder: (context, index) {
                var item = items[index];
                return ListTile(
                  title: Text(item),
                  onTap: () {
                    var orderInvoiceFile = index == 0
                        ? PrintInvoiceType.partner_today_order_invoice
                        : index == 1
                            ? PrintInvoiceType
                                .partner_today_order_by_product_invoice
                            : index == 2
                                ? PrintInvoiceType
                                    .partner_tomorrow_order_invoice
                                : PrintInvoiceType
                                    .partner_tomorrow_order_by_product_invoice;

                    controller.printOrder(orderInvoiceFile);
                    Get.back();
                  },
                );
              },
            ));
      },
    );
  }
}
