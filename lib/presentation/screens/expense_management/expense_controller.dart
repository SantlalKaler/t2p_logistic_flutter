import 'package:get/get.dart';
import 'package:t2p_logistic/data/api_services.dart';
import 'package:t2p_logistic/data/status.dart';
import 'package:t2p_logistic/presentation/constants/extension.dart';
import 'package:t2p_logistic/presentation/controllers/user_controller.dart';
import 'package:t2p_logistic/presentation/theme/resource/custom_constants.dart';
import 'package:t2p_logistic/presentation/theme/resource/uri_constants.dart';
import 'package:t2p_logistic/presentation/widgets/custom_snackbar.dart';
import 'package:dio/dio.dart' as dio;

import '../../../domain/Model/expense/ExpenseCategoryListResponse.dart';
import '../../../domain/Model/expense/ExpenseListResponse.dart';

class ExpenseController extends GetxController {
  RxBool isLoading = false.obs;

  RxList<CatSubCatCommon> categories = RxList<CatSubCatCommon>();
  RxList<CatSubCatCommon> subCategories = RxList<CatSubCatCommon>();
  RxList<Expense> expenses = RxList<Expense>();

  ApiService apiService = ApiService();

  setLoading() => isLoading.value = !isLoading.value;

  UserController userController = Get.find();

  String? documentImagePath;
  String? documentImageName;

  setDocumentImages(path, name) {
    documentImagePath = path;
    documentImageName = name;
    update();
  }

  Future getExpenseList() async {
    try {
      setLoading();
      var data = {
        "added_by": userController.userId,
        "expense_type": "1",
        "active": "",
        "office": "",
        "city": "",
        "category": "",
        "sub_category": "",
        "office_type": "",
        "start_date": "",
        "end_date": ""
      };
      var res = await apiService.post(URIConstants.expenseList+"?user_id=${userController.userId}&ip=${userController.ip}&type=Logistic App", {},
          hasQueryParam: true, queryParam: data);
      if (res != null) {
        ExpenseListResponse expenseListResponse =
            ExpenseListResponse.fromJson(res.data);
        if (expenseListResponse.status == Status.success.name &&
            expenseListResponse.expense!.isNotEmpty) {
          expenses.value = expenseListResponse.expense!;
        }
      }
    } finally {
      setLoading();
      update();
    }
  }

  Future getCategories() async {
    try {
      setLoading();
      var res = await apiService.post(URIConstants.expenseCategory+"?user_id=${userController.userId}&ip=${userController.ip}&type=Logistic App", {});
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
      var res = await apiService.post(URIConstants.expenseSubCategory+"?user_id=${userController.userId}&ip=${userController.ip}&type=Logistic App", {},
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
        "date_of_payment": "2024-03-27",
        "comment": comment,
        "office": office,
        "office_type": officeType,
        "expense_type": "1",
        "platform": "app",
      };

      // printValue(data);
      var uploadData = dio.FormData.fromMap({
        'upload': documentImagePath == null
            ? ""
            : await dio.MultipartFile.fromFile(
                documentImagePath!,
                filename: documentImageName,
              )
      });

      var res = await apiService.post(URIConstants.addExpense+"?user_id=${userController.userId}&ip=${userController.ip}&type=Logistic App", uploadData,
          queryParam: data, hasQueryParam: true);

      if (res != null && res.data['status'] == Status.success.name) {
        CustomSnackBar.showSnackBar("", res.data['message'], "");
        getExpenseList();
        Get.back();
      }
    } finally {
      setLoading();
      update();
    }
  }

  Future editExpense(
    String id,
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
        "id": id,
        "category": category,
        "added_by": addedBy,
        "name": name,
        "city": city,
        "sub_category": subCategory,
        "amount": amount,
        "date_of_payment": dateOfPayment.toServerDate(),
        "comment": comment,
        "office": office,
        "office_type": officeType,
        "expense_type": "1",
        "platform": "app",
      };

      var uploadData = dio.FormData.fromMap({
        'upload': documentImagePath == null
            ? ""
            : await dio.MultipartFile.fromFile(
                documentImagePath!,
                filename: documentImageName,
              )
      });

      var res = await apiService.post(URIConstants.updateExpense+"?user_id=${userController.userId}&ip=${userController.ip}&type=Logistic App", uploadData,
          queryParam: data, hasQueryParam: true);

      if (res != null && res.data['status'] == Status.success.name) {
        CustomSnackBar.showSnackBar("", res.data['message'], "");
        getExpenseList();
        Get.back();
      }
    } finally {
      setLoading();
      update();
    }
  }
}
