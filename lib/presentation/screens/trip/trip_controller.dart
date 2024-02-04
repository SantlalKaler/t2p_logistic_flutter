import 'package:get/get.dart';
import 'package:t2p_logistic/domain/Model/user/AddressListResponse.dart';
import 'package:t2p_logistic/domain/Model/user/AddressListResponse.dart';
import 'package:t2p_logistic/domain/Model/user/AddressListResponse.dart';
import 'package:t2p_logistic/domain/Model/user/AddressListResponse.dart';

import '../../../data/api_services.dart';
import '../../../data/status.dart';
import '../../theme/resource/strings_constants.dart';
import '../../widgets/custom_snackbar.dart';

ApiService _apiService = ApiService();

class TripController extends GetxController {

  RxBool isLoading = false.obs;

  setLoading() => isLoading.value = !isLoading.value;

  Rx<Address> pickupAddress = Address().obs;
  Rx<Address> destinationAddress = Address().obs;

  Future addTrip() async {
    setLoading();
    try {
      /*   var response = await _apiService.;
    if (response != null &&
    response.data[StringConstants.status] == Status.success.name) {}
    else {
    CustomSnackBar.showSnackBar(CustomSnackBar.error,
    response?.data[StringConstants.message], CustomSnackBar.error);
    }*/
    }finally{
    setLoading();
    }
  }
}