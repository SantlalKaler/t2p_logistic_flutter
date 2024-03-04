import 'package:get/get.dart';
import 'package:t2p_logistic/data/api_services.dart';
import 'package:t2p_logistic/domain/Model/partner/LogisticBoyListResponse.dart';
import 'package:t2p_logistic/domain/Model/user/VerifyOtpResponse.dart';
import 'package:t2p_logistic/domain/enums/other.dart';
import 'package:t2p_logistic/presentation/controllers/user_controller.dart';
import 'package:t2p_logistic/presentation/theme/resource/uri_constants.dart';
import 'package:t2p_logistic/presentation/widgets/custom_snackbar.dart';

import '../../../../data/status.dart';

ApiService _apiService = ApiService();

class DeliveryBoyController extends GetxController {
  RxBool isLoading = false.obs;
  RxList<User> boyList = RxList();

  setLoading() => isLoading.value = !isLoading.value;
  UserController userController = Get.find();

  Future getListLogisticBoy() async {
    setLoading();

    try {
      var userType = UserType.delivery_boy.name;

      var data = {"master": userController.userId, "user_type": userType};
      var response = await _apiService.post(URIConstants.listLogisticBoy, data);

      if (response != null) {
        LogisticBoyListResponse boyListResponse =
            LogisticBoyListResponse.fromJson(response.data);
        if (boyListResponse.user!.isNotEmpty) {
          boyList.value = boyListResponse.user!;
        }
      }

      update();
    } finally {
      setLoading();
    }
  }

  Future userStatusChange(String id) async {
    //setLoading();

    try {
      var data = {"id": id};
      var response =
          await _apiService.post(URIConstants.employeeStatusChange, data);

      if (response != null && response.data['status'] == Status.success.name) {
        getListLogisticBoy();
      } else {
        CustomSnackBar.showSnackBar(
            CustomSnackBar.error,
            response?.data['message'] ?? "Something went wrong",
            CustomSnackBar.error);
      }

      update();
    } finally {
     // setLoading();
    }
  }
}
