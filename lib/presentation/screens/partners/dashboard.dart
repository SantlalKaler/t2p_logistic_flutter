import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:t2p_logistic/domain/dashboard_item.dart';
import 'package:t2p_logistic/domain/enums/add_edit_delivery_boy.dart';
import 'package:t2p_logistic/presentation/controllers/user_controller.dart';
import 'package:t2p_logistic/presentation/screens/order_list/order_list.dart';
import 'package:t2p_logistic/presentation/screens/partners/boy/manage_delivery_boy.dart';
import 'package:t2p_logistic/presentation/screens/partners/dashboard_controller.dart';
import 'package:t2p_logistic/presentation/screens/profile/my_profile.dart';
import 'package:t2p_logistic/presentation/screens/trip/trip_list.dart';
import 'package:t2p_logistic/presentation/theme/resource/dimens.dart';
import 'package:t2p_logistic/presentation/widgets/app_bar.dart';
import 'package:t2p_logistic/presentation/widgets/app_image.dart';

import '../../dialogs/default_dialog.dart';
import '../../widgets/app_scaffold.dart';
import 'boy/add_delivery_boy.dart';
import 'cod/cod_collection.dart';
import 'financial_log/financial_log.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  DashboardController controller = Get.find();

  @override
  Widget build(BuildContext context) {
    return appScaffold(
        appBar(title: "Hello", centerTitle: true, actions: [
          IconButton(
              onPressed: () {
                showDialog(
                    context: context,
                    builder: (context) {
                      return DefaultDialog(
                        icon: const Icon(
                          Icons.logout,
                          size: 50,
                        ),
                        message: "Do you really want to log out?",
                        btn1Txt: "Confirm",
                        btn1Click: () {
                          //clear user
                          UserController userController = Get.find();
                          userController.clearUser();
                        },
                        btn2Txt: "Cancel",
                        btn2Click: () {
                          Get.back();
                        },
                      );
                    });
              },
              icon: const Icon(Icons.logout))
        ]),
        Padding(
          padding: EdgeInsets.all(DimensConstants.screePadding),
          child: Container(
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10), color: Colors.white),
              child: GridView.count(
                crossAxisCount: 2,
                children: List.generate(
                    controller.dashboardItems.length,
                    (index) => InkWell(
                          onTap: () {
                            switch (controller.dashboardItems[index].id) {
                              case DashboardItemId.addDeliveryBoy:
                                Get.to(() => const AddDeliveryBoy(addEditDeliveryBoy: AddEditDeliveryBoy.add,));
                              case DashboardItemId.manageDeliveryBoy:
                                Get.to(() => const ManageDeliveryBoy());
                              /*case DashboardItemId.viewAssignOrders:
                                Get.to(() => const OrderList());*/
                              case DashboardItemId.myOrders:
                                Get.to(() => const OrderList());
                              case DashboardItemId.financialLogs:
                                Get.to(() => const FinancialLogs());
                              case DashboardItemId.reports:
                                break;
                              case DashboardItemId.myProfile:
                                Get.to(() => const MyProfileScreen());
                              case DashboardItemId.myTrips:
                                Get.to(() => const TripListScreen());
                              case DashboardItemId.codCollection:
                                Get.to(() => const CodCollectionScreen());
                            }
                          },
                          child:
                              singleGridItem(controller.dashboardItems[index]),
                        )),
              )),
        ));
  }
}

singleGridItem(DashboardItem item) {
  return SizedBox(
    height: 70,
    child: Column(
      children: [
        getAssetImage(item.icon, width: double.infinity, height: 100),
        const Gap(10),
        Text(item.title),
        const Gap(10),
        const Divider(
          thickness: 1,
        )
      ],
    ),
  );
}
