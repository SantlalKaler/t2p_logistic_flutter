import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:t2p_logistic/domain/enums/user_type.dart';
import 'package:t2p_logistic/domain/mapper/order_mapper.dart';
import 'package:t2p_logistic/presentation/controllers/user_controller.dart';
import 'package:t2p_logistic/presentation/dialogs/default_dialog.dart';
import 'package:t2p_logistic/presentation/screens/order_list/order_bottom_sheet.dart';
import 'package:t2p_logistic/presentation/theme/resource/color_constant.dart';
import 'package:t2p_logistic/presentation/widgets/app_container.dart';
import 'package:t2p_logistic/presentation/widgets/app_empty_view.dart';
import 'package:t2p_logistic/presentation/widgets/circular_loadings.dart';

import '../../../domain/Model/single_filter_item.dart';
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
                      preferredSize: const Size(double.infinity, 160),
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
      /* FilterItem(
          title: "Date Range",
          id: FilterItemId.dateRange,
          icon: Icons.calendar_month),
      FilterItem(
          title: "Pickup Boy", id: FilterItemId.pickupBoy, icon: Icons.person),
      FilterItem(
          title: "City", id: FilterItemId.city, icon: Icons.location_city),
      FilterItem(
          title: "Status",
          id: FilterItemId.status,
          icon: Icons.signal_wifi_statusbar_4_bar),*/
    ];

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
                  showModalBottomSheet(
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
                                    controller
                                        .changeT2POrderType(T2POrderType.T2P);
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
                                    controller
                                        .changeT2POrderType(T2POrderType.AF2AP);
                                  }
                                  Get.back();
                                })
                          ],
                        ),
                      );
                    },
                  );
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
                order.paymentMode,
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
                  title: order.pickupAddress,
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 7),
                  child: verticalDivider(),
                ),
                singleAddressItem(
                  title: order.deliveryAddress,
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
                        ? order.pickupBoy
                        : order.deliveryBoy,
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
                title: "Pickup Weight : ${order.pickupWeight} KG",
                height: 5,
                width: 5,
                color: Colors.red),
            singleAddressItem(
                title: "Delivery Weight : ${order.deliveryWeight} KG",
                height: 5,
                width: 5,
                color: Colors.red)
          ],
        ),
        Gap(DimensConstants.spaceBetweenViews),
        singleAddressItem(
            title: "Product : ", height: 5, width: 5, color: Colors.red),
        Text(order.productNames),
        Gap(DimensConstants.spaceBetweenViews),
        singleAddressItem(
            title: "Express : ${order.express}",
            height: 5,
            width: 5,
            color: Colors.red),
        Gap(DimensConstants.spaceBetweenViews),
        singleAddressItem(
            title: "Custom Mobile : ${order.customerNumber}",
            height: 5,
            width: 5,
            color: Colors.red),
        Gap(DimensConstants.spaceBetweenViews),
        singleAddressItem(
            title: "Custom Address : ${order.customerAddress}",
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
            singleAddressItem(
                title: "Delivery Time : ${order.deliveryTime}",
                height: 5,
                width: 5,
                color: Colors.red)
          ],
        ),
        Gap(DimensConstants.spaceBetweenViews),
        singleAddressItem(
            title:
                "Assign to : ${controller.orderType == OrderType.pickup ? order.pickupBoy : order.deliveryBoy}",
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
                value: controller.orderSelected(order.id),
                onChanged: (value) {
                  if (value != null) {
                    controller.selectOrder(order.id);
                  }
                },
                title: const Text(
                  "Select Order",
                ),
                controlAffinity: ListTileControlAffinity.leading,
              ),
            ),
            if (controller.orderType == OrderType.pickup && userController.userType == UserType.delivery_boy.name)
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
                                return DefaultDialog(
                                  message: "Enter product weight",
                                  btn1Txt: "Update",
                                  btn1Click: () {
                                    Get.back();
                                    controller.updatePickupOrderWeight(order.id, weightController.text);
                                  },
                                  btn2Txt: "Cancel",
                                  btn2Click: () {
                                    Get.back();
                                  },
                                  icon: TextFormField(
                                    controller: weightController,
                                    keyboardType: TextInputType.phone,
                                    decoration: const InputDecoration(
                                        label: Text("Enter Weight")),
                                    validator: (value) {
                                      if (value!.isEmpty || value.length < 10) {
                                        return "Enter Weight";
                                      }
                                      return null;
                                    },
                                  ),
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
          overflow: TextOverflow.visible,
        ),
      )
    ],
  );
}
