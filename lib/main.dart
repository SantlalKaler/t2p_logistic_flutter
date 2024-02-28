import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:t2p_logistic/presentation/conectivity_controller.dart';
import 'package:t2p_logistic/presentation/controllers/user_controller.dart';
import 'package:t2p_logistic/presentation/screens/address/address_controller.dart';
import 'package:t2p_logistic/presentation/screens/address/map_location_controller.dart';
import 'package:t2p_logistic/presentation/screens/auth/auth_controller.dart';
import 'package:t2p_logistic/presentation/screens/order_list/order_controller.dart';
import 'package:t2p_logistic/presentation/screens/partners/boy/DeliveryBoyController.dart';
import 'package:t2p_logistic/presentation/screens/partners/boy/add_delivery_boy_controller.dart';
import 'package:t2p_logistic/presentation/screens/partners/cod/cod_collection_controller.dart';
import 'package:t2p_logistic/presentation/screens/partners/dashboard_controller.dart';
import 'package:t2p_logistic/presentation/screens/partners/financial_log/financial_log_controller.dart';
import 'package:t2p_logistic/presentation/screens/splash/setting_controller.dart';
import 'package:t2p_logistic/presentation/screens/splash/splash_screen.dart';
import 'package:t2p_logistic/presentation/screens/trip/trip_controller.dart';
import 'package:t2p_logistic/presentation/theme/theme_light.dart';

import 'presentation/theme/resource/strings_constants.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  //await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: StringConstants.appName,
      themeMode: ThemeMode.light,
      theme: LightTheme.getTheme(),
      home: const SplashScreen(),
      initialBinding: InitialBindings(),
    );
  }
}


class InitialBindings extends Bindings {
  @override
  void dependencies() {
    Get.put(UserController());
    Get.put(SettingsController());
    Get.put(AuthController());
    Get.put(ConnectivityController());
    Get.put(DashboardController());
    Get.put(AddDeliveryBoyController());
    Get.put(OrderController());
    Get.put(DeliveryBoyController());
    Get.put(FinancialLogController());
    Get.put(AddressController());
    Get.put(MapLocationController());
    Get.put(TripController());
    Get.put(CodCollectionController());
  }
}
