import 'dart:async';
import 'package:get/get.dart' as getx;
import 'package:dio/dio.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';

import '../presentation/conectivity_controller.dart';
import '../presentation/screens/auth/auth_controller.dart';
import '../presentation/theme/resource/uri_constants.dart';
import '../presentation/widgets/custom_snackbar.dart';

class ApiService {
  AuthController authController = getx.Get.put(AuthController());
  final Dio _dio = Dio();

  ApiService() {
    _dio.interceptors.add(PrettyDioLogger(
        requestHeader: false,
        requestBody: true,
        responseBody: false,
        responseHeader: false,
        error: true,
        compact: true,
        maxWidth: 120000));
  }

  //get method supports additional headers & authrization
  Future<Response?> get(String path,
      {bool? isAuthorized,
      Map<String, dynamic>? additionalHeaders,
      bool? customBaseURI}) async {
    ConnectivityController connectivityController = getx.Get.find();
    if (connectivityController.isInternetAvailable.isTrue) {
      final Map<String, dynamic> headers = {};
      if (isAuthorized == true) {
        headers['Authorization'] = 'Bearer ${authController.accessToken.value}';
      }
      try {
        final response = await _dio.get(
            customBaseURI == null ? (URIConstants.baseURI + path) : path,
            options: Options(headers: headers));
        return response;
      } catch (error) {
        _handleError(error);
        rethrow;
      }
    } else {
      CustomSnackBar.showSnackBar(CustomSnackBar.error,
          'No connection available', CustomSnackBar.error);
      return null;
    }
  }

  //post method supports additional headers & authrization
  Future<Response?> post(String path, dynamic data,
      {bool? isAuthorized,
      bool hasQueryParam = false,
        Map<String, dynamic>? queryParam,
      Map<String, dynamic>? additionalHeaders,
      bool? customBaseURI}) async {
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
            options: Options(headers: headers))
            :await _dio.post(
            customBaseURI == null ? (URIConstants.baseURI + path) : path,
            data: data,
            options: Options(headers: headers));
        return response;
      } catch (error) {
        _handleError(error);
        rethrow;
      }
    } else {
      CustomSnackBar.showSnackBar(CustomSnackBar.error,
          'No connection available', CustomSnackBar.error);
      return null;
    }
  }

  void _handleError(dynamic error) {
    if (error is DioError) {
      final dioError = error;
      if (dioError.response != null) {
        // Handle DioError with a response (e.g., server returned an error)
        // final errorMessage = dioError.response!.data.toString();
        CustomSnackBar.showSnackBar(CustomSnackBar.error,
            'An unexpected error occurred.', CustomSnackBar.error);
      } else {
        // Handle DioError without a response (e.g., network connectivity issue)

        CustomSnackBar.showSnackBar(
            CustomSnackBar.error,
            'Network error. Please check your connection.',
            CustomSnackBar.error);
      }
    } else {
      // Handle generic errors (e.g., unexpected errors)
      CustomSnackBar.showSnackBar(CustomSnackBar.error,
          'An unexpected error occurred.', CustomSnackBar.error);
    }
  }
}
