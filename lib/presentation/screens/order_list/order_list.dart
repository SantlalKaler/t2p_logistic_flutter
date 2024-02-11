import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:t2p_logistic/domain/enums/user_type.dart';
import 'package:t2p_logistic/domain/mapper/order_mapper.dart';
import 'package:t2p_logistic/presentation/constants/extension.dart';
import 'package:t2p_logistic/presentation/controllers/user_controller.dart';
import 'package:t2p_logistic/presentation/dialogs/default_dialog.dart';
import 'package:t2p_logistic/presentation/screens/order_list/order_bottom_sheet.dart';
import 'package:t2p_logistic/presentation/theme/resource/color_constant.dart';
import 'package:t2p_logistic/presentation/widgets/app_container.dart';
import 'package:t2p_logistic/presentation/widgets/app_empty_view.dart';
import 'package:t2p_logistic/presentation/widgets/circular_loadings.dart';
import 'package:t2p_logistic/presentation/widgets/custom_snackbar.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../domain/Model/single_filter_item.dart';
import '../../dialogs/af2ap_product_dialog.dart';
import '../../theme/resource/dimens.dart';
import 'order_controller.dart';

class OrderList extends StatefulWidget {
  const OrderList({super.key});

  @override
  State<OrderList> createState() => _OrderListState();
}

class _OrderListState extends State<OrderList>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late OrderController controller;
  UserController userController = Get.find();

  TextEditingController weightController = TextEditingController();

  @override
  void initState() {
    Get.delete<OrderController>();
    controller = Get.put(OrderController());

    _tabController = TabController(initialIndex: 0, length: 2, vsync: this);
    controller.getOrders();

    //when user change pickup to deliver or deliver to pickup
    _tabController.addListener(() {
      controller.changeOrderType(_tabController.index);
    });
    super.initState();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder(
        init: OrderController(),
        builder: (controller) {
          return Scaffold(
            bottomNavigationBar: const OrderBottomSheet(),
            body: NestedScrollView(
              headerSliverBuilder: (context, innerBoxIsScrolled) {
                var pickupCount = "";
                var deliveryCount = "";
                if (controller.t2pOrderType == T2POrderType.T2P) {
                  pickupCount = controller.t2pPickupOrders.length.toString();
                  deliveryCount =
                      controller.t2pDeliveryOrders.length.toString();
                } else {
                  pickupCount = controller.aF2APPickupOrders.length.toString();
                  deliveryCount =
                      controller.aF2APDeliveryOrders.length.toString();
                }

                return [
                  SliverAppBar(
                    pinned: true,
                    floating: true,
                    title: const Text("My Orders"),
                    leading: IconButton(
                        onPressed: () {
                          Get.back();
                        },
                        icon: const Icon(Icons.arrow_back_ios)),
                    bottom: PreferredSize(
                      preferredSize: Size(
                          double.infinity,
                          userController.userType ==
                                  UserType.delivery_partner.name
                              ? 160
                              : 100),
                      child: Column(
                        children: [
                          TabBar(
                              controller: _tabController,
                              indicatorColor: Colors.green,
                              indicatorWeight: 5,
                              tabs: [
                                Tab(
                                  text: "Pickup($pickupCount)",
                                ),
                                Tab(
                                  text: "Deliver($deliveryCount)",
                                ),
                              ]),
                          if (userController.userType ==
                              UserType.delivery_partner.name)
                            CheckboxListTile(
                              checkColor: Colors.green,
                              value: controller.allOrderSelected(),
                              onChanged: (value) {
                                if (value != null) {
                                  controller.changeSelectAllOrders(value);
                                }
                              },
                              title: const Text(
                                "Select All Orders",
                                style: TextStyle(color: Colors.white),
                              ),
                              controlAffinity: ListTileControlAffinity.leading,
                            ),
                          Container(
                            height: 48,
                            color: ColorConstants.screenBackgroundColor,
                            child: chipList(),
                          ),
                        ],
                      ),
                    ),
                  ),
                ];
              },
              body: TabBarView(controller: _tabController, children: [
                //pickup orders
                controller.pickupLoading.isTrue && _tabController.index == 0
                    ? circularloadingRedSmallInfinitySize()
                    : (controller.t2pOrderType == T2POrderType.T2P &&
                                controller.t2pPickupOrders.isEmpty ||
                            controller.t2pOrderType == T2POrderType.AF2AP &&
                                controller.aF2APPickupOrders.isEmpty)
                        ? const AppEmptyView(message: "No Orders Found.")
                        : ListView.builder(
                            itemCount:
                                controller.t2pOrderType == T2POrderType.T2P
                                    ? controller.t2pPickupOrders.length
                                    : controller.aF2APPickupOrders.length,
                            itemBuilder: (context, index) {
                              return Padding(
                                padding: EdgeInsets.symmetric(
                                    horizontal: DimensConstants.screePadding,
                                    vertical: DimensConstants
                                        .spaceBetweenViewsAndSubViews),
                                child: singleOrder(
                                    controller.t2pOrderType == T2POrderType.T2P
                                        ? controller.t2pPickupOrders[index]
                                        : controller.aF2APPickupOrders[index]),
                              );
                            },
                          ),

                //delivery orders
                controller.deliveryLoading.isTrue && _tabController.index == 1
                    ? circularloadingRedSmallInfinitySize()
                    : (controller.t2pOrderType == T2POrderType.T2P &&
                                controller.t2pDeliveryOrders.isEmpty ||
                            controller.t2pOrderType == T2POrderType.AF2AP &&
                                controller.aF2APDeliveryOrders.isEmpty)
                        ? const AppEmptyView(message: "No Orders Found.")
                        : ListView.builder(
                            itemCount:
                                controller.t2pOrderType == T2POrderType.T2P
                                    ? controller.t2pDeliveryOrders.length
                                    : controller.aF2APDeliveryOrders.length,
                            itemBuilder: (context, index) {
                              //printValue(controller.t2pDeliveryOrders.length);
                              return Padding(
                                padding: EdgeInsets.symmetric(
                                    horizontal: DimensConstants.screePadding,
                                    vertical: DimensConstants
                                        .spaceBetweenViewsAndSubViews),
                                child: singleOrder(controller.t2pOrderType ==
                                        T2POrderType.T2P
                                    ? controller.t2pDeliveryOrders[index]
                                    : controller.aF2APDeliveryOrders[index]),
                              );
                            },
                          )
              ]),
            ),
          );
        });
  }

  chipList() {
    var chipList = [
      FilterItem(
          title: controller.t2pOrderType.name,
          id: FilterItemId.orderType,
          icon: Icons.shop),
      FilterItem(title: "Print", id: FilterItemId.print, icon: Icons.shop),
    ];

    // add item according to user
    if (userController.userType == UserType.delivery_partner.name) {
      chipList.add(FilterItem(
          title: "Change Status", id: FilterItemId.status, icon: Icons.shop));
    }

    return Container(
      width: double.infinity,
      color: ColorConstants.screenBackgroundColor,
      child: ListView.separated(
          shrinkWrap: true,
          scrollDirection: Axis.horizontal,
          itemBuilder: (context, index) {
            var item = chipList[index];
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
                    // TODO: Handle this case.
                    case FilterItemId.status:
                      if (controller.canAssignOrStart()) {
                        showStatus();
                      } else {
                        CustomSnackBar.showSnackBar(CustomSnackBar.error,
                            "Select Order", CustomSnackBar.error);
                      }
                      break;
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
          itemCount: chipList.length),
    );
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

  showStatus() {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: false,
      builder: (context) {
        var items = controller.orderType == OrderType.pickup
            ? controller.pickupOrderStatus
            : controller.deliveryOrderStatus;
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

  singleOrder(CommonOrder order) {
    // check for selected order
    /*printValue("List update ${controller.orderType}\n"
        "Index is ${_tabController.index}");*/

    return appContainer(Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(vertical: 1, horizontal: 10),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(100), color: Colors.red),
              child: Text(
                order.paymentMode!,
                style: const TextStyle(color: Colors.white),
              ),
            ),
            Text(
              "Order No : ${order.orderId}\n${order.createdAt}",
              textAlign: TextAlign.end,
              style: const TextStyle(color: Colors.grey),
            )
          ],
        ),
        Gap(DimensConstants.spaceBetweenViews),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                singleAddressItem(
                  title: order.pickupCity!,
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 7),
                  child: verticalDivider(),
                ),
                singleAddressItem(
                  title: order.deliveryCity!,
                ),
              ],
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text("Rs. ${order.price}"),
                Gap(DimensConstants.spaceBetweenViews),
                Container(
                  padding:
                      const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: Colors.green.shade50),
                  child: Text(
                    controller.orderType == OrderType.pickup
                        ? order.pickupBoy!
                        : order.deliveryBoy!,
                    style: const TextStyle(color: Colors.green),
                  ),
                ),
              ],
            )
          ],
        ),
        Gap(DimensConstants.highSpacing),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            singleAddressItem(
                title: "Pickup Weight : ${order.pickupWeight.toFixString()} KG",
                height: 5,
                width: 5,
                color: Colors.red),
          ],
        ),
        Gap(DimensConstants.spaceBetweenViews),
        singleAddressItem(
            title: "Delivery Weight : ${order.deliveryWeight.toFixString()} KG",
            height: 5,
            width: 5,
            color: Colors.red),
        Gap(DimensConstants.spaceBetweenViews),
        singleAddressItem(
            title: "Product : ", height: 5, width: 5, color: Colors.red),
        Text(order.productNames!),
        Gap(DimensConstants.spaceBetweenViews),
        singleAddressItem(
            title: "Express : ${order.express}",
            height: 5,
            width: 5,
            color: Colors.red),
        Gap(DimensConstants.spaceBetweenViews),
        InkWell(
          onTap: () async {
            launchDialer(order.customerNumber!);
          },
          child: singleAddressItem(
              title: "Customer Mobile : ${order.customerNumber}",
              height: 5,
              width: 5,
              color: Colors.red),
        ),
        Gap(DimensConstants.spaceBetweenViews),
        singleAddressItem(
            title: "Customer Address : \n${order.customerAddress}",
            height: 5,
            width: 5,
            color: Colors.red),
        /*Gap(DimensConstants.spaceBetweenViews),
        singleAddressItem(
            title: "Payment Mode : ", height: 5, width: 5, color: Colors.red),*/
        Gap(DimensConstants.spaceBetweenViews),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            singleAddressItem(
                title: "Delivery Date : ${order.deliveryDate}",
                height: 5,
                width: 5,
                color: Colors.red),
          ],
        ),
        Gap(DimensConstants.spaceBetweenViews),
        singleAddressItem(
            title: "Delivery Time : ${order.deliveryTime}",
            height: 5,
            width: 5,
            color: Colors.red),
        Gap(DimensConstants.spaceBetweenViews),
        singleAddressItem(
            title: "Status : ${order.orderStatus}",
            height: 5,
            width: 5,
            color: Colors.red),
        //Gap(DimensConstants.spaceBetweenViews),
        Row(
          children: [
            Expanded(
              child: CheckboxListTile(
                tileColor: Theme.of(context).primaryColor,
                checkColor: Colors.green,
                value: controller.orderSelected(order.id!),
                onChanged: (value) {
                  if (value != null) {
                    controller.selectOrder(order.id!);
                  }
                },
                title: const Text(
                  "Select Order",
                ),
                controlAffinity: ListTileControlAffinity.leading,
              ),
            ),

            /** who can update t2p order weight
                1. partner, of pickup orders
                2. boy, of delivery orders
                <----------------------------->
                who can update af2ap order weight, height, width, length
                1. only pickup boy **/

            if (userController.userType == UserType.delivery_boy.name &&
                controller.orderType == OrderType.pickup)
              Expanded(
                  child: controller.updateButtonLoading.isTrue
                      ? Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [circularloadingRedSmall()],
                        )
                      : TextButton(
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (context) {
                                return controller.t2pOrderType ==
                                        T2POrderType.T2P
                                    ? t2pWeightUpdateDialog(order.id!)
                                    : AF2APProductDialog(
                                        order: order,
                                      );
                              },
                            );
                          },
                          child: const Text("Update"))),
          ],
        ),
        /* SizedBox(
          height: 30,
          child: SwipeableButtonView(
            buttonText: 'Start Order',
            buttonWidget: const Icon(
              Icons.arrow_forward_ios_rounded,
              color: Colors.grey,
            ),
            activeColor: const Color(0xFFB71C1C),
            isFinished: isFinished,
            onWaitingProcess: () {
              Future.delayed(const Duration(seconds: 2), () {
                setState(() {
                  isFinished = false;
                });
              });
            },
            onFinish: () async {
              setState(() {
                isFinished = false;
              });
            },
          ),
        )*/
      ],
    ));
  }

  void launchDialer(String phoneNumer) async {
    String url = "tel:$phoneNumer";
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    } else {
      throw 'Could not launch $url';
    }
  }

  t2pWeightUpdateDialog(String orderId) {
    final formKey = GlobalKey<FormState>();
    return Form(
      key: formKey,
      child: DefaultDialog(
        message: "Enter product weight",
        btn1Txt: "Update",
        btn1Click: () {
          if (formKey.currentState!.validate()) {
            Get.back();
            controller.updateT2POrderWeight(orderId, weightController.text);
          }
        },
        btn2Txt: "Cancel",
        btn2Click: () {
          Get.back();
        },
        icon: TextFormField(
          controller: weightController,
          keyboardType: TextInputType.phone,
          decoration: const InputDecoration(label: Text("Enter Weight")),
          validator: (value) {
            if (value!.isEmpty) {
              return "Enter Weight";
            }
            return null;
          },
        ),
      ),
    );
  }

  verticalDivider() {
    return Container(
      height: 30,
      width: 1,
      color: Colors.grey,
    );
  }
}

singleAddressItem({
  String title = "",
  double height = 15,
  double width = 15,
  Color color = Colors.yellow,
}) {
  return Row(
    children: [
      Container(
        height: height,
        width: width,
        decoration: BoxDecoration(shape: BoxShape.circle, color: color),
      ),
      Padding(
        padding:
            EdgeInsets.only(left: DimensConstants.spaceBetweenViewsAndSubViews),
        child: Text(
          title,
          maxLines: 20,
          softWrap: true,
          overflow: TextOverflow.ellipsis,
        ),
      )
    ],
  );
}
