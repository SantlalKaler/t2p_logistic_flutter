import 'package:dio/dio.dart' as dio;
import 'package:get/get.dart';

import '../../../data/api_services.dart';
import '../../../domain/Model/expense/expense_v1.dart';
import '../../theme/resource/uri_constants.dart';
import '../../widgets/custom_snackbar.dart';

class ExpenseController extends GetxController {
  final ApiService apiService;
  ExpenseController({ApiService? apiService})
    : apiService = apiService ?? ApiService();
  static const base = URIConstants.expensesV1;
  bool isLoading = false;
  bool isSaving = false;
  String error = '';
  int? lastStatusCode;
  Map<String, dynamic> meta = {};
  List<ExpenseRecord> expenses = [];
  Map<String, dynamic> totals = {};
  Map<String, dynamic> ledger = {};
  Map<String, String> fieldErrors = {};
  int page = 1, pages = 1;
  String status = '', category = '', search = '', from = '', to = '';
  DateTime? retryAt;
  int _generation = 0;
  final changeRevision = 0.obs;
  String changedExpenseId = '';
  void notifyChanged(String id) {
    changedExpenseId = id;
    changeRevision.value++;
  }

  void resetSession() {
    _generation++;
    meta = {};
    expenses = [];
    totals = {};
    ledger = {};
    fieldErrors = {};
    error = '';
    status = '';
    category = '';
    search = '';
    from = '';
    to = '';
    page = 1;
    pages = 1;
    retryAt = null;
    isLoading = false;
    isSaving = false;
    update();
  }

  Future<Map<String, dynamic>> request(
    String path, {
    String method = 'GET',
    dynamic data,
    Map<String, dynamic>? query,
  }) async {
    if (retryAt != null && DateTime.now().isBefore(retryAt!)) {
      throw ExpenseApiException(
        429,
        'Please wait ${retryAt!.difference(DateTime.now()).inSeconds + 1} seconds and retry.',
      );
    }
    try {
      return expenseMap(
        (await apiService.expenseRequest(
          path,
          method: method,
          data: data,
          query: query,
        )).data,
      );
    } on ExpenseApiException catch (e) {
      if (e.statusCode == 429) {
        retryAt = DateTime.now().add(Duration(seconds: e.retryAfter ?? 30));
      }
      rethrow;
    }
  }

  void showError(Object e) {
    error = '$e';
    lastStatusCode = e is ExpenseApiException ? e.statusCode : null;
    if (e is ExpenseApiException) fieldErrors = e.fields;
    if (Get.context != null) CustomSnackBar.showSnackBar('Error', error, '');
    update();
  }

  Future<void> initialize() async {
    isLoading = true;
    error = '';
    update();
    final generation = _generation;
    try {
      if (meta.isEmpty) {
        final response = await request('$base/meta');
        if (generation != _generation) return;
        meta = expenseMap(response['data']);
      }
      await getExpenseList();
      await loadLedger();
    } catch (e) {
      if (generation == _generation) showError(e);
    } finally {
      if (generation == _generation) {
        isLoading = false;
        update();
      }
    }
  }

  Future<void> getExpenseList({int nextPage = 1}) async {
    final generation = _generation;
    isLoading = true;
    error = '';
    update();
    try {
      final response = await request(
        base,
        query: {
          'page': nextPage,
          'limit': 20,
          if (status.isNotEmpty) 'status': status,
          if (category.isNotEmpty) 'category': category,
          if (search.isNotEmpty) 'q': search,
          if (from.isNotEmpty) 'from': from,
          if (to.isNotEmpty) 'to': to,
          'sort': 'expense_date',
          'dir': 'desc',
        },
      );
      if (generation != _generation) return;
      expenses = expenseMaps(response['data'])
          .map(ExpenseRecord.fromJson)
          .toList();
      totals = expenseMap(response['totals']);
      final pagination = expenseMap(response['pagination']);
      page = expenseNumber(pagination['page']).toInt();
      pages = expenseNumber(pagination['pages']).toInt();
    } catch (e) {
      if (generation == _generation) showError(e);
    } finally {
      if (generation == _generation) {
        isLoading = false;
        update();
      }
    }
  }

  Future<void> loadLedger({
    int nextPage = 1,
    String from = '',
    String to = '',
    String type = '',
  }) async {
    final generation = _generation;
    final response = await request(
      URIConstants.cashLedgerV1,
      query: {
        'page': nextPage,
        'limit': 50,
        if (from.isNotEmpty) 'from': from,
        if (to.isNotEmpty) 'to': to,
        if (type.isNotEmpty) 'type': type,
      },
    );
    if (generation != _generation) return;
    ledger = expenseMap(response['data']);
    update();
  }

  Future<ExpenseDetail> getDetail(String id) async =>
      ExpenseDetail.fromJson((await request('$base/$id'))['data']);

  Future<List<Map<String, dynamic>>> lookup(
    String name, {
    Map<String, dynamic>? query,
  }) async =>
      expenseMaps((await request('$base/lookups/$name', query: query))['data']);

  Future<Map<String, dynamic>> lookupData(
    String name, {
    Map<String, dynamic>? query,
  }) async =>
      expenseMap((await request('$base/lookups/$name', query: query))['data']);

  Future<ExpenseDetail?> save(Map<String, dynamic> body, {String? id}) async {
    if (isSaving) return null;
    isSaving = true;
    fieldErrors = {};
    lastStatusCode = null;
    update();
    try {
      final response = await request(
        id == null ? base : '$base/$id',
        method: id == null ? 'POST' : 'PATCH',
        data: body,
      );
      final result = ExpenseDetail.fromJson(response['data']);
      _notice(response);
      return result;
    } catch (e) {
      showError(e);
      return null;
    } finally {
      isSaving = false;
      update();
    }
  }

  Future<ExpenseDetail> action(
    ExpenseDetail detail,
    String action, {
    String? reason,
  }) async {
    final response = await request(
      '$base/${detail.expense.id}/$action',
      method: 'POST',
      data: {
        if (action != 'approve' && detail.expense.version != null)
          'version': detail.expense.version,
        'reason': ?reason,
      },
    );
    _notice(response);
    return ExpenseDetail.fromJson(response['data']);
  }

  void _notice(Map<String, dynamic> response) {
    final message = [
      response['message'],
      response['warning'],
    ].where((e) => e != null && '$e'.isNotEmpty).join('\n');
    if (message.isNotEmpty && Get.context != null) {
      CustomSnackBar.showSnackBar('', message, '');
    }
  }

  Future<void> upload(String id, List<dio.MultipartFile> files) async {
    final data = dio.FormData();
    for (final file in files) {
      data.files.add(MapEntry('files', file));
    }
    await request('$base/$id/documents', method: 'POST', data: data);
  }

  Future<void> removeDocument(String id, String docId) async =>
      request('$base/$id/documents/$docId', method: 'DELETE');
}
