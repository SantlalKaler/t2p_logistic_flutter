import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:t2p_logistic/data/api_services.dart';
import 'package:t2p_logistic/domain/Model/partner/CodExpenseListResponse.dart';
import 'package:t2p_logistic/presentation/controllers/user_controller.dart';
import 'package:t2p_logistic/presentation/theme/resource/custom_constants.dart';
import 'package:t2p_logistic/presentation/theme/resource/uri_constants.dart';

import '../../../../domain/Model/partner/cod_collection_status.dart';
import '../../../../domain/Model/single_filter_item.dart';
import '../../../../domain/enums/other.dart';

class CodCollectionController extends GetxController {
  ApiService apiService = ApiService();
  UserController userController = Get.find();
  RxList<CodExpense> filterCodExpenseList = RxList();
  RxList<CodExpense> codExpenseList = RxList();
  RxList<City> cityList = RxList();
  RxString totalExpense = "".obs;
  Rxn<CodExpenseListResponse> codExpenseListResponse = Rxn();
  Rxn<City> selectedCity = Rxn();
  Rxn<CodCollectionStatus> selectedStatus = Rxn();
  String userId = "";
  RxString city = "City".obs;
  RxString status = "Status".obs;

  RxBool loading = false.obs;

  String cityId = "";

  setLoading() => loading.value = !loading.value;

  List<FilterItem> get chipList => [
        FilterItem(
            title: selectedCity.value?.name ?? "City", id: FilterItemId.city),
        FilterItem(title: status.value, id: FilterItemId.status),
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

  filterByCity(City city) {
    selectedCity.value = city;
    update();
    getCodExpenseList();
  }

  filterByStatus(CodCollectionStatus status) {
    selectedStatus.value = status;
    List<CodExpense> expense = [];
    for (var cod in filterCodExpenseList) {
      // if(cod)
    }
  }

  Future getCodExpenseList() async {
    userId = userController.userId;
    setLoading();
    try {
      var data = {
        "city": selectedCity.value == null ? "" : selectedCity.value!.id,
        "page": "",
        "limit": "",
        "active": "",
        "added_by": userId,
        "start_date": "",
        "end_date": "",
      };
      var response = await apiService.post(URIConstants.codExpenseList, {},
          queryParam: data, hasQueryParam: true);

      if (response?.data != null) {
        codExpenseListResponse.value =
            CodExpenseListResponse.fromJson(response?.data);
        totalExpense.value = codExpenseListResponse.value!.sum ?? "";
        if (codExpenseListResponse.value!.codExpenses!.isNotEmpty) {
          codExpenseList.value = codExpenseListResponse.value!.codExpenses!;
          //cityList.clear();
          for (var cod in codExpenseList) {
            var cityNames = cityList.map((element) => element.name).toList();
            if (!cityNames.contains(cod.city!.name)) {
              cityList.add(cod.city!);
            }
          }
        }
      }

      filterCodExpenseList.assignAll(codExpenseList);
      update();
    } finally {
      setLoading();
      update();
    }
  }
}
