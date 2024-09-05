import 'dart:async';

import 'package:get/get.dart';
import 'package:country_ip/country_ip.dart';
import 'package:t2p_logistic/presentation/controllers/user_controller.dart';
import 'package:t2p_logistic/presentation/screens/partners/dashboard.dart';
import 'package:t2p_logistic/presentation/theme/resource/uri_constants.dart';

import '../../../data/api_services.dart';
import '../../theme/resource/custom_constants.dart';
import '../auth/auth_screen.dart';

class SettingsController extends GetxController {
  ApiService apiService = ApiService();
  UserController controller = Get.find();

  moveToNext() async {
    Timer(const Duration(seconds: 1), () async {
      getUserIp();
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
    UserController userController = Get.find();
    try {
      var res = await apiService
          .post(URIConstants.isDeactivateUser+"?user_id=${userController.userId}&ip=${userController.ip}&type=Logistic App", {"id": controller.userId});
      if (res != null && res.data["status"] != 0) {
        Get.offAll(() => const DashboardScreen());
      } else {
        Get.offAll(() => const AuthScreen());
      }
    } finally {}
  }

  Future<void> getUserIp() async {
    final countryIpResponse = await CountryIp.find();

    printValue("countryIpResponse : $countryIpResponse");
    printValue("User's country code : ${countryIpResponse?.countryCode}");
    printValue("User's country : ${countryIpResponse?.country}");
    printValue("User's ip : ${countryIpResponse?.ip}");

    var userIPAddress = countryIpResponse?.ip ?? "";
    UserController userController = Get.find();
    userController.saveIpAddress(userIPAddress);
  }
}
