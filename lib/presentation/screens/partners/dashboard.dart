import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:t2p_logistic/domain/dashboard_item.dart';
import 'package:t2p_logistic/domain/enums/add_edit_delivery_boy.dart';
import 'package:t2p_logistic/domain/enums/other.dart';
import 'package:t2p_logistic/presentation/controllers/user_controller.dart';
import 'package:t2p_logistic/presentation/screens/expense_management/expense_list.dart';
import 'package:t2p_logistic/presentation/screens/order_list/order_list.dart';
import 'package:t2p_logistic/presentation/screens/partners/boy/manage_delivery_boy.dart';
import 'package:t2p_logistic/presentation/screens/partners/dashboard_controller.dart';
import 'package:t2p_logistic/presentation/screens/partners/purchase_inward/purchase_inward.dart';
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

class _DashboardScreenState extends State<DashboardScreen>
    with SingleTickerProviderStateMixin {
  DashboardController controller = Get.find();
  UserController userController = Get.find();
  late AnimationController animationController;
  late List<Animation<Offset>> slideAnimations;

  @override
  void initState() {
    var itemLength = userController.userType == UserType.delivery_partner.name
        ? controller.partnerDashboardItems.length
        : userController.userType == UserType.delivery_boy.name
            ? controller.boyDashboardItems.length
            : controller.headDashboardItems.length;
    animationController =
        AnimationController(vsync: this, duration: const Duration(seconds: 1));
    slideAnimations = List.generate(
        itemLength,
        (index) => Tween(begin: const Offset(-2, 0), end: Offset.zero).animate(
            CurvedAnimation(
                parent: animationController,
                curve: Interval(index * (1 / itemLength), 1))));

    animationController.forward();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return appScaffold(
        appBar(
            title: "Hello ${userController.userName}",
            centerTitle: true,
            actions: [
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
              // here dashboard items are change according to user type
              child: GridView.count(
                crossAxisCount: 2,
                children: List.generate(
                    userController.userType == UserType.delivery_partner.name
                        ? controller.partnerDashboardItems.length
                        : userController.userType == UserType.delivery_boy.name
                            ? controller.boyDashboardItems.length
                            : controller.headDashboardItems.length,
                    (index) => SlideTransition(
                          position: slideAnimations[index],
                          child: InkWell(
                            onTap: () {
                              switch (userController.userType ==
                                      UserType.delivery_partner.name
                                  ? controller.partnerDashboardItems[index].id
                                  : userController.userType ==
                                          UserType.delivery_boy.name
                                      ? controller.boyDashboardItems[index].id
                                      : controller
                                          .headDashboardItems[index].id) {
                                case DashboardItemId.addUser:
                                  Get.to(() => const AddUser(
                                        addEditDeliveryBoy:
                                            AddEditDeliveryBoy.add,
                                      ));
                                case DashboardItemId.manageDeliveryBoy:
                                  Get.to(() => const ManageDeliveryBoy());
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
                                case DashboardItemId.expenseManagement:
                                  Get.to(() => const ExpenseListScreen());
                                case DashboardItemId.purchaseInward:
                                  Get.to(() => const PurchaseInwardList());
                              }
                            },
                            child: singleGridItem(userController.userType ==
                                    UserType.delivery_partner.name
                                ? controller.partnerDashboardItems[index]
                                : userController.userType ==
                                        UserType.delivery_boy.name
                                    ? controller.boyDashboardItems[index]
                                    : controller.headDashboardItems[index]),
                          ),
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
