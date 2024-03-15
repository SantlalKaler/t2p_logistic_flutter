class DashboardItem {
  final String icon;
  final String title;
  final DashboardItemId id;

  const DashboardItem(
    this.title,
    this.icon,
    this.id,
  );
}

enum DashboardItemId {
  addUser,
  manageDeliveryBoy,
  //viewAssignOrders,
  myOrders,
  financialLogs,
  reports,
  myProfile,
  myTrips,
  codCollection,
  expenseManagement
}
