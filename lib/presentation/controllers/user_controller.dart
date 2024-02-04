import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:t2p_logistic/domain/Model/user/VerifyOtpResponse.dart';
import 'package:t2p_logistic/presentation/screens/auth/auth_controller.dart';
import 'package:t2p_logistic/presentation/theme/resource/getstorage_keys_constants.dart';

import '../screens/auth/auth_screen.dart';
import '../theme/resource/custom_constants.dart';

class UserController extends GetxController {
  final box = GetStorage();

  String get userId => box.read(GetStorageKeys.userId);

  bool get isLoggedIn => box.read(GetStorageKeys.isLoggedIn) ?? false;

  String get userName => box.read(GetStorageKeys.userName);

  String get userEmail => box.read(GetStorageKeys.userEmail);

  String get userMobile => box.read(GetStorageKeys.userMobile);

  String get userType => box.read(GetStorageKeys.userType);

  saveUser(User user) {
    final Map<String, dynamic> userMap = {
      GetStorageKeys.isLoggedIn: true,
      GetStorageKeys.userId: user.id,
      GetStorageKeys.userName: user.fullName,
      GetStorageKeys.userMobile: user.mobile,
      GetStorageKeys.userEmail: user.email,
      GetStorageKeys.userType: user.userType,
    };

    userMap.forEach((key, value) {
      box.write(key, value);
    });
  }

  getSavedUserInfo() {
    printValue(
        "User Id : $userId\nUser Type : $userType\nUser Name : $userName\n");
  }

  clearUser() {
    box.remove(GetStorageKeys.userId);
    box.remove(GetStorageKeys.userName);
    box.remove(GetStorageKeys.userEmail);
    box.remove(GetStorageKeys.userMobile);
    box.remove(GetStorageKeys.userType);
    box.write(GetStorageKeys.isLoggedIn, false);

    AuthController controller = Get.find();
    controller.isOTPSent.value = false;
    Get.offAll(() => const AuthScreen());
  }
}
