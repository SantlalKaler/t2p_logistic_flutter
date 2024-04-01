import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:dio/dio.dart' as dio;
import 'package:t2p_logistic/data/api_services.dart';
import 'package:t2p_logistic/data/status.dart';
import 'package:t2p_logistic/domain/Model/partner/CodExpenseListResponse.dart';
import 'package:t2p_logistic/presentation/constants/extension.dart';
import 'package:t2p_logistic/presentation/controllers/user_controller.dart';
import 'package:t2p_logistic/presentation/theme/resource/custom_constants.dart';
import 'package:t2p_logistic/presentation/theme/resource/uri_constants.dart';
import 'package:t2p_logistic/presentation/widgets/custom_snackbar.dart';

import '../../../../domain/Model/partner/LogisticBoyListResponse.dart';
import '../../../../domain/Model/partner/cod_collection_status.dart';
import '../../../../domain/Model/single_filter_item.dart';
import '../../../../domain/Model/user/VerifyOtpResponse.dart';
import '../../../../domain/Model/user/user.dart';
import '../../../../domain/enums/other.dart';

class CodCollectionController extends GetxController {
  ApiService apiService = ApiService();
  UserController userController = Get.find();

  RxList<CodExpense> filterCodExpenseList = RxList();
  RxList<CodExpense> codExpenseList = RxList();
  RxList<User> boyList = RxList();
  RxList<City> cityList = RxList();

  RxString totalExpense = "".obs;
  Rxn<CodExpenseListResponse> codExpenseListResponse = Rxn();

  Rxn<City> selectedCity = Rxn();
  Rxn<CodCollectionStatus> selectedStatus = Rxn();
  Rxn<DateTime> selectedStartDate = Rxn();
  Rxn<DateTime> selectedEndDate = Rxn();
  Rxn<DateTime> dateOfPayment = Rxn();
  Rxn<String> selectedDeliveryBoy = Rxn();

  String userId = "";

  RxBool loading = false.obs;

  String cityId = "";

  String? documentImagePath;
  String? documentImageName;

  setDocumentImages(path, name) {
    documentImagePath = path;
    documentImageName = name;
    update();
  }

  setLoading() => loading.value = !loading.value;

  setDateOfPayment(DateTime dateTime) {
    dateOfPayment.value = dateTime;
    update();
  }

  setSelectedItem(FilterItemId itemId, {DateTime? date, int? index}) {
    if (itemId == FilterItemId.startDate) {
      selectedStartDate.value = date;
    }
    if (itemId == FilterItemId.endDate) {
      selectedEndDate.value = date;
    }
    if (itemId == FilterItemId.city) {
      selectedCity.value = cityList[index!];
    }
    if (itemId == FilterItemId.status) {
      selectedStatus.value = statusList[index!];
    }
    update();
  }

  clearFilter() {
    selectedCity.value = null;
    selectedStatus.value = null;
    selectedStartDate.value = null;
    selectedEndDate.value = null;
    update();
    getCodExpenseList();
  }

  List<FilterItem> get chipList => [
        FilterItem(
            title: selectedStartDate.value != null
                ? selectedStartDate.value.toString().toDate()
                : "Start Date",
            id: FilterItemId.startDate),
        FilterItem(
            title: selectedEndDate.value != null
                ? selectedEndDate.value.toString().toDate()
                : "End Date",
            id: FilterItemId.endDate),
        FilterItem(
            title: selectedCity.value?.name ?? "City", id: FilterItemId.city),
        FilterItem(
            title: selectedStatus.value?.name?.toUpperCase() ?? "Status",
            id: FilterItemId.status),
      ];

  List<CodCollectionStatus> get statusList => [
        CodCollectionStatus(
            id: 0, name: CodStatus.pending.name, color: Colors.yellow),
        CodCollectionStatus(
            id: 1, name: CodStatus.reject.name, color: Colors.red),
        CodCollectionStatus(
            id: 3, name: CodStatus.accepted.name, color: Colors.green),
        CodCollectionStatus(
            id: 4, name: CodStatus.submitted.name, color: Colors.green),
      ];

  clearCityFilter() {
    selectedCity.value = null;
  }

  Future getCodExpenseList() async {
    userId = userController.userId;
    setLoading();
    update();
    try {
      var data = {
        "city": selectedCity.value == null ? "" : selectedCity.value!.id,
        "page": "",
        "limit": "",
        "active": selectedStatus.value == null ? "" : selectedStatus.value!.id!,
        "added_by": userId,
        "start_date": selectedStartDate.value == null
            ? ""
            : selectedStartDate.value.toString().toDate(),
        "end_date": selectedEndDate.value == null
            ? ""
            : selectedEndDate.value.toString().toDate(),
      };
      var response = await apiService.post(URIConstants.codExpenseList, {},
          queryParam: data, hasQueryParam: true);

      if (response?.data != null) {
        codExpenseListResponse.value =
            CodExpenseListResponse.fromJson(response?.data);
        totalExpense.value = codExpenseListResponse.value!.sum ?? "";
        if (codExpenseListResponse.value!.codExpenses!.isNotEmpty) {
          codExpenseList.assignAll(codExpenseListResponse.value!.codExpenses!);
          for (var cod in codExpenseList) {
            var cityNames = cityList.map((element) => element.name).toList();
            if (!cityNames.contains(cod.city!.name)) {
              cityList.add(cod.city!);
            }
          }
        }
      }

      filterCodExpenseList.assignAll(codExpenseList);
      printValue("cod list length: ${filterCodExpenseList.length}");
      update();
    } finally {
      setLoading();
      update();
    }
  }

  Future getListLogisticBoy() async {
    setLoading();

    try {
      var userType = UserType.delivery_boy.name;

      var data = {"master": userController.userId, "user_type": userType};
      var response = await apiService.post(URIConstants.listLogisticBoy, data);

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

  updateCodExpense(
    String paymentReceived,
    String dateOfPayment,
    String deliveryBoy,
    String orderId,
    String comment,
  ) async {
    try {
      setLoading();
      update();
      var formData = {
        'date_of_payment': dateOfPayment.toServerDate(),
        'comment': comment,
        'delivery_boy': getDeliveryBoyIdByName(deliveryBoy),
        'payment_received': paymentReceived,
        'id': orderId,
        'file': documentImagePath == null
            ? ""
            : await dio.MultipartFile.fromFile(
                documentImagePath!,
                filename: documentImageName,
              ),
      };

      var response = await apiService.post(URIConstants.updateCodExpense, {},
          queryParam: formData, hasQueryParam: true);

      CustomSnackBar.showSnackBar(CustomSnackBar.error,
          response?.data?['message'], CustomSnackBar.error);

      if (response?.data?['status'] == Status.success.name) {
        Get.back();
      }
    } finally {
      setLoading();
      update();
    }
  }

  getDeliveryBoyIdByName(String deliveryBoy) {
    for (var boy in boyList) {
      if (boy.fullName == deliveryBoy) {
        return boy.id;
      }
    }
  }
}
