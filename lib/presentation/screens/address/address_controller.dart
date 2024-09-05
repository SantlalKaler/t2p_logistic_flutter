import 'package:get/get.dart';
import 'package:t2p_logistic/presentation/controllers/user_controller.dart';
import 'package:t2p_logistic/presentation/theme/resource/custom_constants.dart';
import 'package:t2p_logistic/presentation/theme/resource/uri_constants.dart';

import '../../../data/api_services.dart';
import '../../../data/status.dart';
import '../../../domain/Model/user/AddressListResponse.dart';
import '../../../domain/enums/add_edit_delivery_boy.dart';
import '../../theme/resource/strings_constants.dart';
import '../../widgets/custom_snackbar.dart';

ApiService _apiService = ApiService();

class AddressController extends GetxController {
  RxBool isLoading = false.obs;
  RxBool isAddingEdittingAddress = false.obs;
  RxBool isLoadingAllStates = false.obs;
  RxBool isLoadingCityByStates = false.obs;
  RxBool isLoadingZipCodeByCity = false.obs;

  UserController userController = Get.find();

  Rx<AddressType> selectedAddressType = AddressType.home.obs;
  RxBool isLocationOnMapSelected = false.obs;

  List<AddressType> addressTypes = [
    AddressType.home,
    AddressType.work,
    AddressType.other
  ];
  RxList<Address> addressList = RxList<Address>();
  RxList<State> stateList = RxList<State>();
  RxList<City> cityList = RxList<City>();
  RxList<City> allCities = RxList<City>();
  RxList<City> zipList = RxList<City>();
  RxDouble lat = 28.6139.obs;
  RxDouble lng = 77.2090.obs;

  setLoading() => isLoading.value = !isLoading.value;

  Future getAddressList() async {
    setLoading();
    try {
      var url = "${URIConstants.allAddress}?id=${userController.userId}&user_id=${userController.userId}&ip=${userController.ip}&type=Logistic App";
      var response = await _apiService.get(url);
      if (response != null &&
          response.data[StringConstants.status] == Status.success.name) {
        addressList.clear();
        AddressListResponse addressListResponse =
            AddressListResponse.fromJson(response.data);
        if (addressListResponse.address != null &&
            addressListResponse.address!.isNotEmpty) {
          addressList.value = addressListResponse.address!;
        }
      } else {
        CustomSnackBar.showSnackBar(CustomSnackBar.error,
            response?.data[StringConstants.message], CustomSnackBar.error);
      }
      update();
    } finally {
      setLoading();
    }
  }

  Future<void> getAllStates() async {
    isLoadingAllStates.value = true;
    try {
      await _apiService.get(URIConstants.stateList+"?user_id=${userController.userId}&ip=${userController.ip}&type=Logistic App").then((response) {
        if (response != null) {
          stateList.clear();
          List result = response.data['result'];
          stateList.value =
              result.map((element) => State.fromJson(element)).toList();
        }
      });
    } finally {
      isLoadingAllStates.value = false;
      update();
    }
  }

  Future<void> getAllCityByStatess(stateId) async {
    isLoadingCityByStates.value = true;

    try {
      await _apiService
          .get("${URIConstants.cityList}?state=$stateId&user_id=${userController.userId}&ip=${userController.ip}&type=Logistic App")
          .then((response) {
        if (response != null) {
          cityList.clear();
          List result = response.data['result'];
          cityList.value =
              result.map((element) => City.fromJson(element)).toList();
        }
      });
    } finally {
      isLoadingCityByStates.value = false;
    }
  }

  Future<void> getZipCodeByCity(cityId) async {
    isLoadingZipCodeByCity.value = true;

    try {
      await _apiService
          .get("${URIConstants.zipList}?city=$cityId&user_id=${userController.userId}&ip=${userController.ip}&type=Logistic App")
          .then((response) {
        if (response != null) {
          zipList.clear();
          List result = response.data['result'];
          zipList.value =
              result.map((element) => City.fromJson(element)).toList();
        }
      });
    } finally {
      isLoadingZipCodeByCity.value = false;
    }
  }

  Future<void> addAddress(
      {String? title,
      String? address,
      String? address2,
      String? cityId,
      String? cityName,
      String? stateId,
      String? stateName,
      String? postOffice,
      String? postalCode,
      String? contactName,
      String? contactPhone,
      String? lat,
      String? lng,
      String? landmark,
      bool? redirectToHome}) async {
    setLoading();

    UserController userController = Get.find();

    var payLoad = {
      "userid": userController.userId,
      "title": title,
      "address": address,
      "address2": address2,
      "city": cityId,
      "state": stateId,
      "post_office": postOffice,
      "pincode": postalCode,
      "contact_name": contactName,
      "contact_mobile": contactPhone,
      "lat": lat,
      "lng": lng,
      // "landmark": landmark
    };

    try {
      await _apiService
          .post(URIConstants.addAddress+"?user_id=${userController.userId}&ip=${userController.ip}&type=Logistic App", payLoad)
          .then((response) async {
        if (response != null &&
            response.data[StringConstants.status] == Status.success.name) {
          Get.back();
          await getAddressList();
        } else {
          if (response != null &&
              response.data['message']['_message'] != null) {
            CustomSnackBar.showSnackBar(CustomSnackBar.error,
                response.data['message']['_message'], CustomSnackBar.error);
          }
        }
      });
      update();
    } finally {
      setLoading();
    }
  }

  Future<void> editAddress(
      {String? addressId,
      String? title,
      String? address,
      String? address2,
      String? cityId,
      String? cityName,
      String? stateId,
      String? stateName,
      String? postOffice,
      String? postalCode,
      String? contactName,
      String? contactPhone,
      String? lat,
      String? lng,
      String? landmark,
      bool? redirectToHome}) async {
    UserController userController = Get.find();
    // savedLocationController savedLocationController = Get.find();
    isAddingEdittingAddress.value = true;

    var payLoad = {
      'id': addressId,
      "userid": userController.userId,
      "title": title,
      "address": address,
      "address2": address2,
      "city": cityId,
      "state": stateId,
      "post_office": postOffice,
      "pincode": postalCode,
      "contact_name": contactName,
      "contact_mobile": contactPhone,
      "lat": lat,
      "lng": lng,
      "landmark": landmark
    };
    try {
      await _apiService
          .post(URIConstants.editAddress+"?user_id=${userController.userId}&ip=${userController.ip}&type=Logistic App", payLoad)
          .then((response) async {
        if (response != null && response.data['status'] == 'success') {
          Get.back();

          CustomSnackBar.showSnackBar(
              CustomSnackBar.error, 'Address updated', CustomSnackBar.error);
          await getAddressList();
        } else {
          if (response != null &&
              response.data['message']['_message'] != null) {
            CustomSnackBar.showSnackBar(CustomSnackBar.error,
                response.data['message']['_message'], CustomSnackBar.error);
          }
        }
      });
    } finally {
      isAddingEdittingAddress.value = false;
    }
  }

  Future<void> deleteAddress(addressId) async {
    try {
      await _apiService
          .get(URIConstants.deleteAddress + addressId+"&user_id=${userController.userId}&ip=${userController.ip}&type=Logistic App")
          .then((response) {
        if (response != null) {
          if (response.data['status'] == 'success') {
            CustomSnackBar.showSnackBar(CustomSnackBar.success,
                response.data['message'], CustomSnackBar.success);
          } else {
            CustomSnackBar.showSnackBar(CustomSnackBar.error,
                response.data['message'], CustomSnackBar.error);
          }
        }
      });
    } finally {
      await getAddressList();
    }
  }

  Future<void> getAllCities() async {
    allCities.clear();
    try {
      await _apiService.get(URIConstants.allCities+"?user_id=${userController.userId}&ip=${userController.ip}&type=Logistic App").then((response) {
        if (response != null) {
          if (response.data['status'] == 'success' &&
              response.data['result'].isNotEmpty) {
            for (var city in response.data['result']) {
              allCities.add(City.fromJson(city));
            }
          }
        }
      });
    } finally {}
  }
}
