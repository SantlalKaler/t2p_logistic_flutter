import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:get/get.dart' as getx;
import 'package:dio/dio.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';

import '../presentation/conectivity_controller.dart';
import '../domain/Model/expense/expense_v1.dart';
import '../presentation/controllers/user_controller.dart';
import '../presentation/screens/auth/auth_controller.dart';
import '../presentation/theme/resource/uri_constants.dart';
import '../presentation/widgets/custom_snackbar.dart';

class ApiService {
  AuthController authController = getx.Get.isRegistered<AuthController>()
      ? getx.Get.find<AuthController>()
      : getx.Get.put(AuthController());
  final Dio _dio = Dio();

  final Dio _expenseDio;

  ApiService({Dio? expenseDio})
    : _expenseDio =
          expenseDio ??
          Dio(BaseOptions(connectTimeout: const Duration(seconds: 20))) {
    _dio.interceptors.add(
      PrettyDioLogger(
        enabled: kDebugMode,
        requestHeader: true,
        requestBody: true,
        responseBody: true,
        responseHeader: true,
        error: true,
        compact: true,
        maxWidth: 120,
      ),
    );
  }

  //get method supports additional headers & authrization
  Future<Response?> get(
    String path, {
    bool? isAuthorized,
    Map<String, dynamic>? additionalHeaders,
    bool? customBaseURI,
  }) async {
    ConnectivityController connectivityController = getx.Get.find();
    if (connectivityController.isInternetAvailable.isTrue) {
      final Map<String, dynamic> headers = {};
      if (isAuthorized == true) {
        headers['Authorization'] = 'Bearer ${authController.accessToken.value}';
      }
      try {
        final response = await _dio.get(
          customBaseURI == null ? (URIConstants.baseURI + path) : path,
          options: Options(headers: headers),
        );
        return response;
      } catch (error) {
        _handleError(error);
        rethrow;
      }
    } else {
      CustomSnackBar.showSnackBar(
        CustomSnackBar.error,
        'No connection available',
        CustomSnackBar.error,
      );
      return null;
    }
  }

  //post method supports additional headers & authrization
  Future<Response?> post(
    String path,
    dynamic data, {
    bool? isAuthorized,
    bool hasQueryParam = false,
    Map<String, dynamic>? queryParam,
    Map<String, dynamic>? additionalHeaders,
    bool? customBaseURI,
  }) async {
    ConnectivityController connectivityController = getx.Get.find();
    if (connectivityController.isInternetAvailable.isTrue) {
      Map<String, dynamic> headers = {};

      if (isAuthorized == true) {
        headers['Authorization'] = 'Bearer ${authController.accessToken.value}';
      }
      if (additionalHeaders != null) {
        headers.addAll(additionalHeaders);
      }
      try {
        final response = hasQueryParam
            ? await _dio.post(
                customBaseURI == null ? (URIConstants.baseURI + path) : path,
                queryParameters: queryParam,
                data: data,
                options: Options(headers: headers),
              )
            : await _dio.post(
                customBaseURI == null ? (URIConstants.baseURI + path) : path,
                data: data,
                options: Options(headers: headers),
              );
        return response;
      } catch (error) {
        _handleError(error);
        rethrow;
      }
    } else {
      CustomSnackBar.showSnackBar(
        CustomSnackBar.error,
        'No connection available',
        CustomSnackBar.error,
      );
      return null;
    }
  }

  // The expense API has its own JSON envelope and actionable HTTP errors.
  // Existing legacy API callers keep their current behavior.
  Future<Response<dynamic>> expenseRequest(
    String path, {
    String method = 'GET',
    dynamic data,
    Map<String, dynamic>? query,
    ResponseType? responseType,
  }) async {
    final token = await authController.readAccessToken();
    if (token.isEmpty) {
      await getx.Get.find<UserController>().clearUser();
      throw ExpenseApiException(401, 'Please log in again to use Expenses.');
    }
    if (kDebugMode) {
      final files = data is FormData
          ? data.files
          : <MapEntry<String, MultipartFile>>[];
      debugPrint(
        '[Expense API] $method /$path sending${files.isEmpty ? '' : ' multipart: ${files.map((f) => '${f.key} (${f.value.contentType}, ${f.value.length} bytes)').join(', ')}'}',
      );
    }
    try {
      final response = await _expenseDio.request<dynamic>(
        URIConstants.baseURI + path,
        data: data,
        queryParameters: query,
        options: Options(
          method: method,
          responseType: responseType,
          headers: {'Authorization': 'Bearer $token'},
          sendTimeout: const Duration(seconds: 45),
          receiveTimeout: const Duration(seconds: 45),
        ),
      );
      _logExpenseResponse(method, path, response);
      if (response.data is Map && response.data['status'] != 'success') {
        throw ExpenseApiException(
          response.statusCode,
          '${response.data['message'] ?? 'Unable to complete request'}',
        );
      }
      return response;
    } on DioException catch (error) {
      _logExpenseResponse(
        method,
        path,
        error.response,
        failure: error.type.name,
      );
      final code = error.response?.statusCode;
      final body = expenseMap(error.response?.data);
      if (code == 401) {
        await getx.Get.find<UserController>().clearUser();
      }
      throw ExpenseApiException(
        code,
        '${body['message'] ?? (error.response == null ? 'Connection failed. Please check your network and retry.' : 'Unable to complete request. Please try again later.')}',
        fields: {
          for (final e in expenseMaps(body['errors']))
            '${e['field']}': '${e['message']}',
        },
        retryAfter: int.tryParse(
          error.response?.headers.value('retry-after') ?? '',
        ),
      );
    }
  }

  // Diagnostics deliberately omit auth headers, file contents and expense data.
  // Keep this at the call site so hot reload also enables it on existing clients.
  void _logExpenseResponse(
    String method,
    String path,
    Response<dynamic>? response, {
    String? failure,
  }) {
    if (!kDebugMode) return;
    final body = expenseMap(response?.data);
    final message = '${body['message'] ?? ''}'.replaceAll(
      RegExp(r'Bearer\s+\S+', caseSensitive: false),
      'Bearer [redacted]',
    );
    debugPrint(
      '[Expense API] $method /$path -> HTTP ${response?.statusCode ?? 'no response'}'
      ' status=${body['status'] ?? '-'}${failure == null ? '' : ' transport=$failure'}'
      '${message.isEmpty ? '' : ' message=${message.length > 600 ? message.substring(0, 600) : message}'}',
    );
    for (final error in expenseMaps(body['errors'])) {
      debugPrint(
        '[Expense API] field=${error['field']} message=${error['message']}',
      );
    }
  }

  void _handleError(dynamic error) {
    if (error is DioException) {
      final dioError = error;
      if (dioError.response != null) {
        // Handle DioException with a response (e.g., server returned an error)
        // final errorMessage = dioError.response!.data.toString();
        CustomSnackBar.showSnackBar(
          CustomSnackBar.error,
          'An unexpected error occurred.',
          CustomSnackBar.error,
        );
      } else {
        // Handle DioException without a response (e.g., network connectivity issue)

        CustomSnackBar.showSnackBar(
          CustomSnackBar.error,
          'Network error. Please check your connection.',
          CustomSnackBar.error,
        );
      }
    } else {
      // Handle generic errors (e.g., unexpected errors)
      CustomSnackBar.showSnackBar(
        CustomSnackBar.error,
        'An unexpected error occurred.',
        CustomSnackBar.error,
      );
    }
  }
}
