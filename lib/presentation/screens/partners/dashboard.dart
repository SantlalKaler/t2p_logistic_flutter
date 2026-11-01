import '../duty/duty_controller.dart';
import '../duty/duty_widgets.dart';

import 'package:flutter/material.dart';
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
import 'package:t2p_logistic/presentation/widgets/app_image.dart';

import '../../dialogs/default_dialog.dart';
import '../../controllers/expense_notification_controller.dart';
import '../expense_management/components/expense_design.dart';
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
    animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );
    slideAnimations = List.generate(
      itemLength,
      (index) => Tween(begin: const Offset(-2, 0), end: Offset.zero).animate(
        CurvedAnimation(
          parent: animationController,
          curve: Interval(index * (1 / itemLength), 1),
        ),
      ),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Get.find<DutyController>().reconcile();
      if (Get.isRegistered<ExpenseNotificationController>()) {
        final notifications = Get.find<ExpenseNotificationController>();
        notifications.dashboardReady();
      }
    });
    animationController.forward();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: ExpenseDesign.theme(context),
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F6FA),
        appBar: AppBar(
          automaticallyImplyLeading: false,
          toolbarHeight: 84,
          titleSpacing: 20,
          title: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFFDF0F1),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Image.asset('assets/images/app_icon_small.png'),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  "Hello ${userController.userName}",
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: ExpenseDesign.ink,
                  ),
                ),
              ),
            ],
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: IconButton(
                tooltip: 'Logout',
                style: IconButton.styleFrom(
                  foregroundColor: ExpenseDesign.accent,
                  backgroundColor: const Color(0xFFFDF0F1),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) {
                      return DefaultDialog(
                        icon: const Icon(Icons.logout, size: 50),
                        message: "Do you really want to log out?",
                        btn1Txt: "Confirm",
                        btn1Click: () async {
                          final duty = Get.find<DutyController>();
                          if (duty.busy) return;
                          await duty.stop();
                          //clear user
                          UserController userController = Get.find();
                          userController.clearUser();
                        },
                        btn2Txt: "Cancel",
                        btn2Click: () {
                          Get.back();
                        },
                      );
                    },
                  );
                },
                icon: const Icon(Icons.logout_rounded, size: 21),
              ),
            ),
          ],
        ),
        body: SafeArea(
          top: false,
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1120),
              child: CustomScrollView(
                slivers: [
                  const SliverPadding(
                    padding: EdgeInsets.fromLTRB(16, 16, 16, 4),
                    sliver: SliverToBoxAdapter(child: DutyPanel()),
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                    sliver: SliverLayoutBuilder(
                      builder: (context, constraints) {
                        final width = constraints.crossAxisExtent;
                        final columns = width >= 900
                            ? 4
                            : (width >= 600 ? 3 : 2);
                        final textScale =
                            MediaQuery.textScalerOf(context).scale(14) / 14;
                        return SliverGrid(
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: columns,
                                crossAxisSpacing: 12,
                                mainAxisSpacing: 12,
                                mainAxisExtent:
                                    158 + (textScale - 1).clamp(0, 3) * 48,
                              ),
                          delegate: SliverChildListDelegate(
                            List.generate(
                              userController.userType ==
                                      UserType.delivery_partner.name
                                  ? controller.partnerDashboardItems.length
                                  : userController.userType ==
                                        UserType.delivery_boy.name
                                  ? controller.boyDashboardItems.length
                                  : controller.headDashboardItems.length,
                              (index) => SlideTransition(
                                position: slideAnimations[index],
                                child: Material(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(18),
                                  clipBehavior: Clip.antiAlias,
                                  child: InkWell(
                                    borderRadius: BorderRadius.circular(18),
                                    onTap: () {
                                      switch (userController.userType ==
                                              UserType.delivery_partner.name
                                          ? controller
                                                .partnerDashboardItems[index]
                                                .id
                                          : userController.userType ==
                                                UserType.delivery_boy.name
                                          ? controller
                                                .boyDashboardItems[index]
                                                .id
                                          : controller
                                                .headDashboardItems[index]
                                                .id) {
                                        case DashboardItemId.addUser:
                                          Get.to(
                                            () => const AddUser(
                                              addEditDeliveryBoy:
                                                  AddEditDeliveryBoy.add,
                                            ),
                                          );
                                        case DashboardItemId.manageDeliveryBoy:
                                          Get.to(
                                            () => const ManageDeliveryBoy(),
                                          );
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
                                          Get.to(
                                            () => const CodCollectionScreen(),
                                          );
                                        case DashboardItemId.expenseManagement:
                                          Get.to(
                                            () => const ExpenseListScreen(),
                                          );
                                        case DashboardItemId.purchaseInward:
                                          Get.to(
                                            () => const PurchaseInwardList(),
                                          );
                                      }
                                    },
                                    child: singleGridItem(
                                      userController.userType ==
                                              UserType.delivery_partner.name
                                          ? controller
                                                .partnerDashboardItems[index]
                                          : userController.userType ==
                                                UserType.delivery_boy.name
                                          ? controller.boyDashboardItems[index]
                                          : controller
                                                .headDashboardItems[index],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

Widget singleGridItem(DashboardItem item) {
  return Ink(
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(18),
      border: Border.all(color: const Color(0xFFEAECF0)),
    ),
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              getAssetImage(item.icon, width: 68, height: 68),
              const Icon(
                Icons.arrow_outward_rounded,
                size: 17,
                color: Color(0xFF98A2B3),
              ),
            ],
          ),
          const Spacer(),
          Text(
            item.title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: ExpenseDesign.ink,
              height: 1.35,
            ),
          ),
        ],
      ),
    ),
  );
}
