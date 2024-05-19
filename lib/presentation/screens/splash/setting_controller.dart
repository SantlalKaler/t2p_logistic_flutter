import 'dart:async';

import 'package:get/get.dart';
import 'package:t2p_logistic/presentation/controllers/user_controller.dart';
import 'package:t2p_logistic/presentation/screens/partners/dashboard.dart';
import 'package:t2p_logistic/presentation/theme/resource/uri_constants.dart';

import '../../../data/api_services.dart';
import '../auth/auth_screen.dart';

class SettingsController extends GetxController {
  ApiService apiService = ApiService();
  UserController controller = Get.find();

  moveToNext() async {
    Timer(const Duration(seconds: 1), () async {
      UserController controller = Get.find();
      if (controller.isLoggedIn) {
        controller.getSavedUserInfo();
        isDeactivateUser();
        //Get.offAll(() => const DashboardScreen());
      } else {
        Get.offAll(() => const AuthScreen());
      }
    });
  }

  Future isDeactivateUser() async {
    try {
      var res = await apiService
          .post(URIConstants.isDeactivateUser, {"id": controller.userId});
      if (res != null && res.data["status"] != 0) {
        Get.offAll(() => const DashboardScreen());
      } else {
        Get.offAll(() => const AuthScreen());
      }
    } finally {}
  }
}
