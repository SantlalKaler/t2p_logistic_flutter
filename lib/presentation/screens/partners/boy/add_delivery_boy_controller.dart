import 'dart:async';

import 'package:get/get.dart';
import 'package:t2p_logistic/data/status.dart';
import 'package:t2p_logistic/presentation/controllers/user_controller.dart';
import 'package:t2p_logistic/presentation/theme/resource/strings_constants.dart';
import 'package:t2p_logistic/presentation/theme/resource/uri_constants.dart';
import 'package:t2p_logistic/presentation/widgets/custom_snackbar.dart';

import '../../../../data/api_services.dart';
import '../../../../domain/upload_file_item.dart';

ApiService _apiService = ApiService();

class AddDeliveryBoyController extends GetxController {
  RxBool isLoading = false.obs;
  RxBool profileImageLoading = false.obs;
  RxBool voterCardLoading = false.obs;
  RxBool aadharLoading = false.obs;
  RxBool panLoading = false.obs;
  RxBool deliveryBoyAdded = false.obs;

  String? profileImagePath;
  String? profileImageName;

  setProfileImages(path, name) {
    profileImagePath = path;
    profileImageName = name;
    update();
  }

  String? voterImagePath;
  String? voterImageName;

  setVoterImages(path, name) {
    voterImagePath = path;
    voterImageName = name;
    update();
  }

  String? aadharImagePath;
  String? aadharImageName;

  setAadharImages(path, name) {
    aadharImagePath = path;
    aadharImageName = name;
    update();
  }

  String? panImagePath;
  String? panImageName;

  setPanImages(path, name) {
    panImagePath = path;
    panImageName = name;
    update();
  }

  setLoading() => isLoading.value = !isLoading.value;

  List<UploadFileItem> items = [
    const UploadFileItem("Profile Image", UploadFileItemId.profileImage),
    const UploadFileItem("Voter Card", UploadFileItemId.voterCard),
    const UploadFileItem("Aadhar Card", UploadFileItemId.aadharCard),
    const UploadFileItem("Pan Card", UploadFileItemId.panCard),
  ];

  Future addLogisticBoy(
    String fullName,
    String mobile,
    String email,
  ) async {
    setLoading();
    try {
      UserController userController = Get.find();
      var data = {
        "full_name": fullName,
        "mobile": mobile,
        "email": email,
        "master": userController.userId,
        //Todo : Don't send user type here
        "user_type": "delivery_boy"
      };
      var response = await _apiService.post(URIConstants.addLogisticBoy, data);
      if (response != null &&
          response.data[StringConstants.status] == Status.success.name) {
        CustomSnackBar.showSnackBar(CustomSnackBar.error,
            response.data[StringConstants.message], CustomSnackBar.error);
        deliveryBoyAdded.value = true;
      } else {
        CustomSnackBar.showSnackBar(CustomSnackBar.error,
            response?.data[StringConstants.message], CustomSnackBar.error);
        deliveryBoyAdded.value = false;
      }
      update();
    } finally {
      setLoading();
    }
  }

  Future editLogisticBoy(
    String fullName,
    String mobile,
    String email,
    String address,
    String city,
    String zipCode,
    String boyId,
  ) async {
    setLoading();
    try {
      var data = {
        "full_name": fullName,
        "mobile": mobile,
        "email": email,
        "address": address,
        "city": city,
        "service_zipcode": zipCode,
        "id": boyId,
      };
      var response =
          await _apiService.post(URIConstants.updateLogisticBoy, data);

      // todo: Getting update profile error
      if (response != null &&
          response.data[StringConstants.status] == Status.success.name) {
        CustomSnackBar.showSnackBar(CustomSnackBar.error,
            response.data[StringConstants.message], CustomSnackBar.error);
        deliveryBoyAdded.value = true;
      } else {
        CustomSnackBar.showSnackBar(CustomSnackBar.error,
            response?.data[StringConstants.message], CustomSnackBar.error);
        deliveryBoyAdded.value = false;
      }
      update();
    } finally {
      setLoading();
    }
  }

  Future uploadImage(UploadFileItemId uploadFileItemId) async {
    if (uploadFileItemId == UploadFileItemId.profileImage &&
            profileImagePath != null ||
        uploadFileItemId == UploadFileItemId.voterCard &&
            voterImagePath != null ||
        uploadFileItemId == UploadFileItemId.aadharCard &&
            aadharImagePath != null ||
        uploadFileItemId == UploadFileItemId.panCard && panImagePath != null) {
      setUploadImageLoading(uploadFileItemId);
      Timer(const Duration(seconds: 3), () async {
        setUploadImageLoading(uploadFileItemId);
        CustomSnackBar.showSnackBar(CustomSnackBar.error,
            "Image upload successfully", CustomSnackBar.error);
      });
    } else {
      CustomSnackBar.showSnackBar(
          CustomSnackBar.error, "Select Image", CustomSnackBar.error);
    }
  }

  setUploadImageLoading(UploadFileItemId uploadFileItemId) {
    if (uploadFileItemId == UploadFileItemId.profileImage) {
      profileImageLoading.value = !profileImageLoading.value;
    } else if (uploadFileItemId == UploadFileItemId.voterCard) {
      voterCardLoading.value = !voterCardLoading.value;
    } else if (uploadFileItemId == UploadFileItemId.aadharCard) {
      aadharLoading.value = !aadharLoading.value;
    } else if (uploadFileItemId == UploadFileItemId.panCard) {
      panLoading.value = !panLoading.value;
    }
    update();
  }
}
