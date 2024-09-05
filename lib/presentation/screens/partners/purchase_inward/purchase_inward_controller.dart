import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:t2p_logistic/data/status.dart';
import 'package:t2p_logistic/domain/Model/partner/purchase_inward/PurchaseInwardListResponse.dart';
import 'package:t2p_logistic/domain/Model/partner/purchase_inward/SingleInwardResponse.dart';
import 'package:t2p_logistic/presentation/constants/extension.dart';
import 'package:t2p_logistic/presentation/theme/resource/custom_constants.dart';
import 'package:t2p_logistic/presentation/theme/resource/strings_constants.dart';
import 'package:t2p_logistic/presentation/widgets/custom_snackbar.dart';

import '../../../../data/api_services.dart';
import '../../../controllers/user_controller.dart';
import '../../../theme/resource/uri_constants.dart';

class PurchaseInwardController extends GetxController {
  ApiService apiService = ApiService();
  UserController userController = Get.find();
  RxBool loading = false.obs;
  RxBool updatePriceLoading = false.obs;

  RxList<Inward> inwardList = RxList<Inward>();
  RxList<Inward> filterInwardList = RxList<Inward>();
  RxList<ResultProduct> products = RxList<ResultProduct>();
  Rxn<SingleInwardResponse> singleInwardResponse = Rxn<SingleInwardResponse>();

  TextEditingController createdController = TextEditingController();
  TextEditingController poIdController = TextEditingController();
  TextEditingController orderIdController = TextEditingController();
  TextEditingController vendorCityController = TextEditingController();
  TextEditingController totalAmountController = TextEditingController();

  setLoading() => loading.value = !loading.value;

  setUpdatePriceLoading() =>
      updatePriceLoading.value = !updatePriceLoading.value;

  searchInwardByOrderId(String orderId) {
    List<Inward> filterList = [];
    for (var inward in inwardList) {
      printValue("Filter order id is $orderId\nbill No ${inward.billNo}\n"
          "${inward.billNo!.contains(orderId)}");
     // List<String> billNo = inward.billNo!.split(",");
      if (inward.billNo!.contains(orderId)) {
        filterList.add(inward);
      }
    }
    filterInwardList.assignAll(filterList);
    update();
  }

  Future getInwardList() async {
    setLoading();
    try {
      var data = {
        "start_city": userController.officeId,
        "page": "",
        "limit": "",
      };
      var response = await apiService.post(URIConstants.purchaseInwardList+"?user_id=${userController.userId}&ip=${userController.ip}&type=Logistic App", {},
          queryParam: data, hasQueryParam: true);

      if (response?.data != null) {
        PurchaseInwardListResponse purchaseInwardListResponse =
            PurchaseInwardListResponse.fromJson(response!.data);
        if (purchaseInwardListResponse.inwards != null &&
            purchaseInwardListResponse.inwards!.isNotEmpty) {
          inwardList.value = purchaseInwardListResponse.inwards!;
        }
      }

      filterInwardList.assignAll(inwardList);
    } finally {
      setLoading();
      update();
    }
  }

  Future getSingleInward(String id) async {
    setLoading();
    try {
      var data = {"id": id};
      var response = await apiService.post(URIConstants.singleInward+"?user_id=${userController.userId}&ip=${userController.ip}&type=Logistic App", {},
          queryParam: data, hasQueryParam: true);

      if (response?.data != null) {
        singleInwardResponse.value =
            SingleInwardResponse.fromJson(response?.data);
        printValue(
            "Products are : ${singleInwardResponse.value?.resultProduct?.length}\n"
            "${response?.data['result_product']}");
        if (singleInwardResponse.value?.resultProduct != null) {
          products.value = singleInwardResponse.value!.resultProduct!;
        }
        setData();
      }

      filterInwardList.assignAll(inwardList);
    } finally {
      setLoading();
      update();
    }
  }

  setData() {
    Inward inward = singleInwardResponse.value!.inward!;
    createdController.text =
        inward.createdDate!.toDate(outputDate: "dd-MM-yyyy, HH:mm");
    poIdController.text = inward.poId ?? "";
    orderIdController.text = inward.billNo ?? "";
    vendorCityController.text = inward.inwardOffice?.name ?? "";
    totalAmountController.text = inward.amount ?? "";
  }

  Future updateSingleProductPrice(String id, String price) async {
    setUpdatePriceLoading();
    try {
      var data = {
        "id": id,
        "price": price,
      };
      var response = await apiService.post(
          URIConstants.updateInwardProductPurchasePrice+"?user_id=${userController.userId}&ip=${userController.ip}&type=Logistic App", data);

      if (response?.data != null &&
          response!.data[StringConstants.status] == Status.success.name) {
        CustomSnackBar.showSnackBar(
            "", response.data[StringConstants.message], "");
        getSingleInward(singleInwardResponse.value!.inward!.id!);
      }
    } finally {
      setUpdatePriceLoading();
    }
  }
}
