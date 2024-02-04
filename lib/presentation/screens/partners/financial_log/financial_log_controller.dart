import 'package:get/get.dart';
import 'package:t2p_logistic/data/status.dart';
import 'package:t2p_logistic/domain/Model/partner/FinancialLogResponse.dart';
import 'package:t2p_logistic/presentation/controllers/user_controller.dart';
import 'package:t2p_logistic/presentation/theme/resource/strings_constants.dart';
import 'package:t2p_logistic/presentation/theme/resource/uri_constants.dart';

import '../../../../data/api_services.dart';

ApiService _apiService = ApiService();

class FinancialLogController extends GetxController {
  RxBool isLoading = false.obs;
  UserController userController = Get.find();
  RxList<FinancialLog> logList = RxList<FinancialLog>();

  setLoading() => isLoading.value = !isLoading.value;

  Future financialLog() async {
    setLoading();
    try {
      var url =
          "${URIConstants.financialLog}?type=${userController.userType}&id=${userController.userId}";
      var response = await _apiService.get(url);
      if (response != null &&
          response.data[StringConstants.status] == Status.success.name) {
        FinancialLogResponse financialLogResponse =
            FinancialLogResponse.fromJson(response.data);
        logList.value = financialLogResponse.financialLog!;
      update();
      }
    } finally {
      setLoading();
      update();
    }
  }
}

/*
ApiService _apiService = ApiService();
class FinancialLoController extends GetxController{

  RxBool isLoading = false.obs;

  setLoading() => isLoading.value = !isLoading.value;

  Future financialLog()async{
    setLoading();
    try{
var response = await _apiService.;
      if (response != null &&
          response.data[StringConstants.status] == Status.success.name) {}
      else {
        CustomSnackBar.showSnackBar(CustomSnackBar.error,
            response?.data[StringConstants.message], CustomSnackBar.error);
      }
    }finally{
      setLoading();
    }
  }
}*/
