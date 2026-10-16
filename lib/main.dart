import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:get_storage/get_storage.dart';

import 'presentation/controllers/expense_notification_controller.dart';

import 'package:get/get.dart';
import 'package:t2p_logistic/presentation/conectivity_controller.dart';
import 'package:t2p_logistic/presentation/controllers/user_controller.dart';
import 'package:t2p_logistic/presentation/screens/address/address_controller.dart';
import 'package:t2p_logistic/presentation/screens/address/map_location_controller.dart';
import 'package:t2p_logistic/presentation/screens/auth/auth_controller.dart';
import 'package:t2p_logistic/presentation/screens/expense_management/expense_controller.dart';
import 'package:t2p_logistic/presentation/screens/order_list/order_controller.dart';
import 'package:t2p_logistic/presentation/screens/partners/boy/DeliveryBoyController.dart';
import 'package:t2p_logistic/presentation/screens/partners/boy/add_delivery_boy_controller.dart';
import 'package:t2p_logistic/presentation/screens/partners/cod/cod_collection_controller.dart';
import 'package:t2p_logistic/presentation/screens/partners/dashboard_controller.dart';
import 'package:t2p_logistic/presentation/screens/partners/financial_log/financial_log_controller.dart';
import 'package:t2p_logistic/presentation/screens/partners/purchase_inward/purchase_inward_controller.dart';
import 'package:t2p_logistic/presentation/screens/splash/setting_controller.dart';
import 'package:t2p_logistic/presentation/screens/splash/splash_screen.dart';
import 'package:t2p_logistic/presentation/screens/trip/trip_controller.dart';
import 'package:t2p_logistic/presentation/theme/theme_light.dart';

import 'presentation/theme/resource/strings_constants.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await GetStorage.init();
  if (!kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.android ||
          defaultTargetPlatform == TargetPlatform.iOS)) {
    try {
      await Firebase.initializeApp();
    } catch (e) {
      debugPrint('Firebase configuration unavailable: $e');
    }
  }
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
    Get.put(ExpenseController());
    Get.put(ExpenseNotificationController());
    Get.put(DashboardController());
    Get.put(AddDeliveryBoyController());
    Get.put(DeliveryBoyController());
    Get.put(PurchaseInwardController());
    Get.put(AddressController());
    Get.put(OrderController());
    Get.put(FinancialLogController());
    Get.put(MapLocationController());
    Get.put(TripController());
    Get.put(CodCollectionController());
  }
}
