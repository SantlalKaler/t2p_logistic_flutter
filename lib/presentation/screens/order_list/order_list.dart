import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:t2p_logistic/domain/enums/other.dart';
import 'package:t2p_logistic/presentation/controllers/user_controller.dart';
import 'package:t2p_logistic/presentation/screens/address/address_controller.dart';
import 'package:t2p_logistic/presentation/screens/order_list/components/single_order_item.dart';
import 'package:t2p_logistic/presentation/screens/order_list/order_bottom_sheet.dart';
import 'package:t2p_logistic/presentation/theme/resource/color_constant.dart';
import 'package:t2p_logistic/presentation/theme/resource/custom_constants.dart';
import 'package:t2p_logistic/presentation/widgets/app_empty_view.dart';
import 'package:t2p_logistic/presentation/widgets/circular_loadings.dart';

import '../../theme/resource/dimens.dart';
import 'components/chip_list.dart';
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
  AddressController addressController = Get.find();

  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    Get.delete<OrderController>();
    controller = Get.put(OrderController());

    _tabController = TabController(initialIndex: 0, length: 2, vsync: this);
    controller.getOrders();

    //get all cities so that user can filter order based on city
    addressController.getAllCities();

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
                  pickupCount = controller.t2pPickupFilterOrders.length.toString();
                  deliveryCount =
                      controller.t2pDeliveryFilterOrders.length.toString();
                } else {
                  pickupCount =
                      controller.aF2APPickupFilterOrders.length.toString();
                  deliveryCount =
                      controller.aF2APDeliveryFilterOrders.length.toString();
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
                          (userController.userType ==
                                      UserType.delivery_partner.name ||
                                  userController.userType ==
                                      UserType.lp_manager.name ||
                                  userController.userType ==
                                      UserType.lp_head.name)
                              ? 175
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

                          Row(
                            children: [
                              // only delivery partner can select all orders at once
                              if (userController.userType ==
                                      UserType.delivery_partner.name ||
                                  userController.userType ==
                                      UserType.lp_manager.name ||
                                  userController.userType ==
                                      UserType.lp_head.name)
                                Expanded(
                                  child: CheckboxListTile(
                                    contentPadding: const EdgeInsets.all(0),
                                    checkColor: Colors.green,
                                    value: controller.allOrderSelected(),
                                    onChanged: (value) {
                                      if (value != null) {
                                        controller.changeSelectAllOrders(value);
                                      }
                                    },
                                    title: const Text(
                                      "Select All Orders",
                                      style: TextStyle(
                                          color: Colors.white, fontSize: 14),
                                    ),
                                    controlAffinity:
                                        ListTileControlAffinity.leading,
                                  ),
                                ),
                              Expanded(
                                  child: Padding(
                                padding: const EdgeInsets.all(10.0)
                                    .copyWith(left: 0),
                                child: SearchBar(
                                  controller: searchController,
                                  hintText: "Search By Order Id...",
                                  leading: const Icon(
                                    Icons.search,
                                  ),
                                  keyboardType: TextInputType.phone,
                                  onChanged: (value){
                                    printValue("Search value is $value");
                                    controller.searchOrderById(value);
                                  },
                                  elevation: const MaterialStatePropertyAll(0),
                                ),
                              ))
                            ],
                          ),

                          // chip show to all type of user's but it changes according to user
                          Container(
                            height: 48,
                            color: ColorConstants.screenBackgroundColor,
                            child: const ChipList(),
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
                                controller.t2pPickupFilterOrders.isEmpty ||
                            controller.t2pOrderType == T2POrderType.AF2AP &&
                                controller.aF2APPickupFilterOrders.isEmpty)
                        ? const AppEmptyView(message: "No Orders Found.")
                        : ListView.builder(
                            itemCount:
                                controller.t2pOrderType == T2POrderType.T2P
                                    ? controller.t2pPickupFilterOrders.length
                                    : controller.aF2APPickupFilterOrders.length,
                            itemBuilder: (context, index) {
                              return Padding(
                                padding: EdgeInsets.symmetric(
                                    horizontal: DimensConstants.screePadding,
                                    vertical: DimensConstants
                                        .spaceBetweenViewsAndSubViews),
                                child: SingleOrderItem(
                                    order: controller.t2pOrderType ==
                                            T2POrderType.T2P
                                        ? controller.t2pPickupFilterOrders[index]
                                        : controller
                                            .aF2APPickupFilterOrders[index]),
                              );
                            },
                          ),

                //delivery orders
                controller.deliveryLoading.isTrue && _tabController.index == 1
                    ? circularloadingRedSmallInfinitySize()
                    : (controller.t2pOrderType == T2POrderType.T2P &&
                                controller.t2pDeliveryFilterOrders.isEmpty ||
                            controller.t2pOrderType == T2POrderType.AF2AP &&
                                controller.aF2APDeliveryFilterOrders.isEmpty)
                        ? const AppEmptyView(message: "No Orders Found.")
                        : ListView.builder(
                            itemCount: controller.t2pOrderType ==
                                    T2POrderType.T2P
                                ? controller.t2pDeliveryFilterOrders.length
                                : controller.aF2APDeliveryFilterOrders.length,
                            itemBuilder: (context, index) {
                              //printValue(controller.t2pDeliveryOrders.length);
                              return Padding(
                                padding: EdgeInsets.symmetric(
                                    horizontal: DimensConstants.screePadding,
                                    vertical: DimensConstants
                                        .spaceBetweenViewsAndSubViews),
                                child: SingleOrderItem(
                                    order: controller.t2pOrderType ==
                                            T2POrderType.T2P
                                        ? controller.t2pDeliveryFilterOrders[index]
                                        : controller
                                            .aF2APDeliveryFilterOrders[index]),
                              );
                            },
                          )
              ]),
            ),
          );
        });
  }
}
