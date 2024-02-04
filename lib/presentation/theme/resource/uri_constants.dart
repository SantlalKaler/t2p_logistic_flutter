class URIConstants {
  static String baseURI = 'https://webapi.tastes2plate.com/';
  static String amazonBaseURI = 'https://omst5afyma.execute-api.ap-south-1.amazonaws.com/production/app/';

  //auth
  static String login = 'app/logistic-login';
  static String verify = 'app/verify-logistic';

  //logistic boy
  static String listLogisticBoy = 'app/list-logistic-boy';
  static String employeeStatusChange = 'app/employee-status-chnage';

  //pickup partner
  static String partnerPickupOrder = "app/pickup-partner-order";
  static String partnerPickupOrderAF2AP = "app/gharkakhana-pickup-patner-list";
  static String partnerDeliveryOrder = "app/delivery-partner-order";
  static String partnerDeliveryOrderAF2AP = "app/gharkakhana-delivery-partner-list";
  static String addLogisticBoy = "app/add-logistics-boy";
  static String updateLogisticBoy = "app/update-logistic";
  static String financialLog = "app/financial-log";
  static String assignT2PPickupOrder = "app/pickup-partner-order-assign-pickup-boy";
  static String assignT2PDeliveryOrder = "app/delivery-partner-order-assign-delivery-boy";
  static String assignAF2APPickupOrder = "app/gharkakhana-pickup-partner-update";
  static String assignAF2APDeliveryOrder = "app/gharkakhana-delivery-partner-update";
  static String changeOrderStatus = "app/change-order-status";
  static String updatePickupOrderWeight = "app/update-pickup-order-weight";

  //common
  static String allAddress = "app/all-address";
  static String addAddress = "app/add-address";
  static String stateList = "app/state-list";
  static String cityList = "app/city-list-by-state";
  static String zipList = "app/zipcode-by-city";

}
