import 'package:get/get_state_manager/src/simple/get_controllers.dart';
import 'package:t2p_logistic/presentation/theme/resource/image_constants.dart';

import '../../../domain/dashboard_item.dart';

class DashboardController extends GetxController {
  List<DashboardItem> partnerDashboardItems = [
    DashboardItem("Add Delivery Boy", ImageConstants.category1,
        DashboardItemId.addUser),
    DashboardItem("Manage Delivery Boy", ImageConstants.category2,
        DashboardItemId.manageDeliveryBoy),
    /*DashboardItem("View Assigned Orders", ImageConstants.category3,
        DashboardItemId.viewAssignOrders),*/
    DashboardItem(
        "My Orders", ImageConstants.category4, DashboardItemId.myOrders),
    DashboardItem("Financial Logs", ImageConstants.category5,
        DashboardItemId.financialLogs),
    //DashboardItem("Reports", ImageConstants.category6, DashboardItemId.reports),
    DashboardItem(
        "My Profile", ImageConstants.category7, DashboardItemId.myProfile),
    DashboardItem(
        "My Trips", ImageConstants.category8, DashboardItemId.myTrips),
    DashboardItem("Cod Collection", ImageConstants.category9,
        DashboardItemId.codCollection),
  ];

  List<DashboardItem> boyDashboardItems = [
    DashboardItem(
        "My Orders", ImageConstants.category4, DashboardItemId.myOrders),
    DashboardItem("Financial Logs", ImageConstants.category5,
        DashboardItemId.financialLogs),
    DashboardItem(
        "My Profile", ImageConstants.category7, DashboardItemId.myProfile),
    DashboardItem(
        "My Trips", ImageConstants.category8, DashboardItemId.myTrips),
  ];

  List<DashboardItem> headDashboardItems = [
    DashboardItem(
        "My Orders", ImageConstants.category4, DashboardItemId.myOrders),
    /*DashboardItem("Manage LP Manager", ImageConstants.category2,
        DashboardItemId.manageDeliveryBoy),*/
    DashboardItem(
        "My Profile", ImageConstants.category7, DashboardItemId.myProfile),
  ];
}
