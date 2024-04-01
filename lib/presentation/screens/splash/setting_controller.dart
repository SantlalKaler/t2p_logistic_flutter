import 'dart:async';

import 'package:get/get.dart';
import 'package:t2p_logistic/presentation/controllers/user_controller.dart';
import 'package:t2p_logistic/presentation/screens/partners/dashboard.dart';

import '../auth/auth_screen.dart';

class SettingsController extends GetxController {
  moveToNext() async {
    Timer(const Duration(seconds: 1), () async {
      UserController controller = Get.find();
      if (controller.isLoggedIn) {
        controller.getSavedUserInfo();
        Get.offAll(() => const DashboardScreen());
      } else {
        Get.offAll(() => const AuthScreen());
      }
    });
  }
}
