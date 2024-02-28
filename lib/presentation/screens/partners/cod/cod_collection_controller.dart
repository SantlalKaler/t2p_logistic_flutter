import 'package:get/get.dart';
import 'package:t2p_logistic/data/api_services.dart';
import 'package:t2p_logistic/presentation/controllers/user_controller.dart';
import 'package:t2p_logistic/presentation/theme/resource/uri_constants.dart';

class CodCollectionController extends GetxController {
  ApiService apiService = ApiService();
  UserController userController = Get.find();
  String userId = "";

  RxBool loading = false.obs;

  String cityId = "";

  setLoading() => loading.value = !loading.value;

  Future getCodExpenseList() async {
    userId = userController.userId;
    setLoading();
    try {
      var data = {
        "city": cityId,
        "page": "",
        "limit": "",
        "active": "",
        "added_by": userId,
        "start_date": "",
        "end_date": "",
      };
      var response = await apiService.post(URIConstants.codExpenseList, {},
          queryParam: data, hasQueryParam: true);
    } finally {
      setLoading();
    }
  }
}
