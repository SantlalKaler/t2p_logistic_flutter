class URIConstants {
  static String baseURI = 'https://webapi.tastes2plate.com/';
  static String phonePeBaseURI = 'https://mercury-t2.phonepe.com/';
  static String pdfBaseURI = "http://142.93.208.70:2001/app/";
  static String amazonBaseURI =
      'https://omst5afyma.execute-api.ap-south-1.amazonaws.com/production/app/';

  //auth
  static String login = 'app/logistic-login';
  static String verify = 'app/verify-logistic';

  // ---------------------------- boy ---------------------------------
  static String boyPickupOrderT2P = "app/pickup-boy-order-list";
  static String boyDeliveryOrderT2P = "app/delivery-boy-order-list";
  static String boyPickupOrderAF2AP = "app/gharkakhana-pickup-boy-list";
  static String boyDeliveryOrderAF2AP = "app/gharkakhana-pickup-boy-list";
  static String deliveryOrderStart = "app/delivery-boy-order-start";
  static String pickupOrderStart = "app/pickup-boy-order-start";
  static String pickupOrderStartAF2AP = "app/gharkakhana-pickup-boy-order-start";
  static String deliveryOrderStartAF2AP = "app/gharkakhana-delivery-boy-order-start";
  static String deliveredToCargo = "app/delivered-to-cargo";
  static String deliveredToCustomer = "app/delivered-to-customer";
  static String deliveredToCustomerAF2AP = "app/gharkakhana-delivered-order";
  static String sendOTPToCargo = "app/send-otp-to-cargo";
  static String sendOTPToCustomer = "app/send-otp-to-customer";
  static String sendOTPToCustomerAF2AP = "app/gharkakhana-send-otp-to-customer";
  static String updateDeliveryOrderWeight = "app/update-delivery-order-weight";
  static String updateAF2APOrder = "app/gharkakhana-pickup-order";
  static String updateDeliveryDistance = "app/update-delivery-distance";

  // <------------------------- partner --------------------------------
  static String employeeStatusChange = 'app/employee-status-chnage';
  static String allDeliveryStatus = 'app/all-delivery-status';
  static String partnerStatusChange = 'app/partner-status-change';
  static String listLogisticBoy = 'app/list-logistic-boy';
  static String partnerPickupOrder = "app/pickup-partner-order";
  static String partnerPickupOrderAF2AP = "app/gharkakhana-pickup-patner-list";
  static String partnerDeliveryOrder = "app/delivery-partner-order";
  static String partnerDeliveryOrderAF2AP =
      "app/gharkakhana-delivery-partner-list";
  static String addLogisticBoy = "app/add-logistics-boy";
  static String updateLogisticBoy = "app/update-logistic";
  static String financialLog = "app/financial-log";
  static String assignT2PPickupOrder =
      "app/pickup-partner-order-assign-pickup-boy";
  static String assignT2PDeliveryOrder =
      "app/delivery-partner-order-assign-delivery-boy";
  static String assignAF2APPickupOrder =
      "app/gharkakhana-pickup-partner-update";
  static String assignAF2APDeliveryOrder =
      "app/gharkakhana-delivery-partner-update";
  static String changeOrderStatus = "app/change-order-status";
  static String updatePickupOrderWeight = "app/update-pickup-order-weight";
  static String updateCodExpense = "admin/update-cod-expense";


  // <------------------------- manager --------------------------------
  static String lpManagerT2PPickupOrder = "app/lp-manager-pickup-partner-order-list";
  static String lpManagerT2PDeliveryOrder = "app/lp-manager-delivery-partner-order-list";
  static String lpManagerAF2APPickupOrder = "app/ghar-ka-khana-lp-manager-pickup-partner-order-list";
  static String lpManagerAF2APDeliveryOrder = "app/ghar-ka-khana-lp-manager-delivery-partner-order-list";
  static String lpManagerDeliveryPartner = "app/lp-manager-delivery-partner";

  // <------------------------- head --------------------------------

  static String lpManagerList = "app/lp-manager-list";
  static String lpHeadT2PPickupOrder = "app/lp-head-pickup-partner-order-list";
  static String lpHeadT2PDeliveryOrder = "app/lp-head-delivery-partner-order-list";
  static String lpHeadAF2APPickupOrder = "app/ghar-ka-khana-lp-head-pickup-partner-order-list";
  static String lpHeadAF2APDeliveryOrder = "app/ghar-ka-khana-lp-head-delivery-partner-order-list";

  // cod
  static String codExpenseList = "admin/cod-expense-list";

  // ---------------------------------------------------------------->

  //common
  static String allAddress = "app/all-address";
  static String addAddress = "app/add-address";
  static String editAddress = 'app/edit-address';
  static String deleteAddress = 'app/delete-address?id=';
  static String stateList = "app/state-list";
  static String cityList = "app/city-list-by-state";
  static String zipList = "app/zipcode-by-city";

  //payment
  static String getQr = "v3/qr/init";
}
