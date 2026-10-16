import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:t2p_logistic/domain/Model/user/VerifyOtpResponse.dart';
import 'package:t2p_logistic/domain/Model/user/office_data.dart';
import 'package:t2p_logistic/domain/enums/other.dart';
import 'package:t2p_logistic/presentation/controllers/user_controller.dart';
import 'package:t2p_logistic/presentation/screens/partners/dashboard.dart';
import 'package:t2p_logistic/presentation/theme/resource/getstorage_keys_constants.dart';
import 'package:t2p_logistic/presentation/theme/resource/uri_constants.dart';

import '../../../data/api_services.dart';

import 'package:dio/dio.dart' as dio;

import '../../../data/status.dart';
import '../../../domain/Model/user/LogisticLoginResponse.dart';
import '../../../domain/Model/user/user.dart';
import '../../widgets/custom_snackbar.dart';

ApiService _apiService = ApiService();

class AuthController extends GetxController {
  final box = GetStorage();

  RxBool isLoggedIn = false.obs;
  RxBool isGuestUser = false.obs;

  RxBool isSendingOTP = false.obs;
  RxBool isOTPSent = false.obs;
  RxBool isResendOTP = false.obs;
  RxBool isLoading = false.obs;
  RxString accessToken = ''.obs;
  final FlutterSecureStorage _tokenStorage = const FlutterSecureStorage();
  Future<String> readAccessToken() async {
    accessToken.value =
        await _tokenStorage.read(key: 'logistics_access_token') ?? '';
    return accessToken.value;
  }

  Future<void> clearAccessToken() async {
    accessToken.value = '';
    await _tokenStorage.delete(key: 'logistics_access_token');
  }

  Future<void> saveAccessToken(String token) async {
    await _tokenStorage.write(key: 'logistics_access_token', value: token);
    accessToken.value = token;
  }

  Rxn<LogisticLoginResponse> loginResponse = Rxn();
  Rxn<VerifyOtpResponse> verifyOTPResponse = Rxn();
  Rx<TextEditingController> phoneTextController = TextEditingController().obs;
  RxString otpTextController = ''.obs;

  setLoading() => isLoading.value = !isLoading.value;

  @override
  void onInit() {
    super.onInit();
    isLoggedIn.value = box.read(GetStorageKeys.isLoggedIn) ?? false;
  }

  Future sendOtp() async {
    UserController userController = Get.find();
    setLoading();
    try {
      var mobile = phoneTextController.value.text;
      var data = {"mobile": mobile};

      dio.Response? response = await _apiService.post(
        "${URIConstants.login}?ip=${userController.ip}&type=Logistic App",
        data,
      );

      if (response != null && response.data['status'] == Status.success.name) {
        isOTPSent.value = true;
      } else {
        isOTPSent.value = false;
        CustomSnackBar.showSnackBar(
          CustomSnackBar.error,
          response!.data['message'],
          CustomSnackBar.error,
        );
      }
    } finally {
      setLoading();
    }
  }

  Future verifyOtp() async {
    setLoading();

    UserController userController = Get.find();

    try {
      var mobile = phoneTextController.value.text;
      var otp = otpTextController.value;
      var data = {
        "mobile": mobile,
        'otp': otp,
        'device': GetPlatform.isAndroid ? 'android' : 'ios',
      };

      dio.Response? response = await _apiService.post(
        URIConstants.verify,
        data,
      );

      if (response != null && response.data['status'] == Status.success.name) {
        User user = User.fromJson(response.data['result']);

        OfficeData? officeData;
        if (response.data['office_data'] != null) {
          officeData = OfficeData.fromJson(response.data['office_data']);
        }

        //move to next screen
        if (user.userType == UserType.lp_head.name ||
            user.userType == UserType.lp_manager.name ||
            user.userType == UserType.delivery_partner.name ||
            user.userType == UserType.delivery_boy.name ||
            user.userType == 'pickup_boy' ||
            user.userType == 'pickup_partner' ||
            user.userType == 'cargo_partner') {
          await saveAccessToken('${response.data['token'] ?? ''}');
          userController.saveUser(user, officeData);
          cleartextControllers();
          Get.offAll(() => const DashboardScreen());
        } else {
          CustomSnackBar.showSnackBar(
            CustomSnackBar.error,
            "UnAuthorized User",
            CustomSnackBar.error,
          );
        }
      } else {
        CustomSnackBar.showSnackBar(
          CustomSnackBar.error,
          response!.data['message'],
          CustomSnackBar.error,
        );
      }
    } finally {
      setLoading();
    }
  }

  void cleartextControllers() {
    phoneTextController.value.text = '';
    otpTextController.value = '';
  }
}
