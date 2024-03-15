import 'package:get/get.dart';
import 'package:t2p_logistic/data/api_services.dart';
import 'package:t2p_logistic/data/status.dart';
import 'package:t2p_logistic/presentation/theme/resource/uri_constants.dart';
import 'package:t2p_logistic/presentation/widgets/custom_snackbar.dart';

import '../../../domain/Model/expense/ExpenseCategoryListResponse.dart';

class ExpenseController extends GetxController {
  RxBool isLoading = false.obs;

  RxList<CatSubCatCommon> categories = RxList<CatSubCatCommon>();
  RxList<CatSubCatCommon> subCategories = RxList<CatSubCatCommon>();

  ApiService apiService = ApiService();

  setLoading() => isLoading.value = !isLoading.value;

  String? documentImagePath;
  String? documentImageName;

  setDocumentImages(path, name) {
    documentImagePath = path;
    documentImageName = name;
    update();
  }

  Future getCategories() async {
    try {
      setLoading();
      var res = await apiService.post(URIConstants.expenseCategory, {});
      if (res != null) {
        ExpenseCatSubCatListResponse expenseCatSubCatListResponse =
            ExpenseCatSubCatListResponse.fromJson(res.data);

        if (expenseCatSubCatListResponse.status == Status.success.name &&
            expenseCatSubCatListResponse.result != null &&
            expenseCatSubCatListResponse.result!.isNotEmpty) {
          categories.value = expenseCatSubCatListResponse.result!;
        }
      }
    } finally {
      setLoading();
      update();
    }
  }

  Future getSubCategories(String categoryId) async {
    try {
      setLoading();
      var res = await apiService.post(URIConstants.expenseSubCategory, {},
          queryParam: {"parent": categoryId}, hasQueryParam: true);

      if (res != null) {
        ExpenseCatSubCatListResponse expenseCatSubCatListResponse =
            ExpenseCatSubCatListResponse.fromJson(res.data);

        if (expenseCatSubCatListResponse.status == Status.success.name &&
            expenseCatSubCatListResponse.result != null &&
            expenseCatSubCatListResponse.result!.isNotEmpty) {
          subCategories.value = expenseCatSubCatListResponse.result!;
        }
      }
    } finally {
      setLoading();
      update();
    }
  }

  Future addExpense(
    String category,
    String subCategory,
    String addedBy,
    String name,
    String city,
    String amount,
    String dateOfPayment,
    String comment,
    String office,
    String officeType,
  ) async {
    try {
      setLoading();
      var data = {
        "category": category,
        "added_by": addedBy,
        "name": name,
        "city": city,
        "sub_category": subCategory,
        "amount": amount,
        "date_of_payment": dateOfPayment,
        "comment": comment,
        "office": office,
        "office_type": officeType,
      };

      var res = await apiService.post(URIConstants.addExpense, {},
          queryParam: data, hasQueryParam: true);

      if (res != null && res.data['status'] == Status.success.name) {
        CustomSnackBar.showSnackBar("", res.data['message'], "");
        Get.back();
      }
    } finally {
      setLoading();
      update();
    }
  }
}
