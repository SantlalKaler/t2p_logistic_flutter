import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:t2p_logistic/domain/Model/user/AddressListResponse.dart';
import 'package:t2p_logistic/domain/Model/user/AddressListResponse.dart';
import 'package:t2p_logistic/domain/Model/user/AddressListResponse.dart';
import 'package:t2p_logistic/domain/Model/user/AddressListResponse.dart';

import 'package:http/http.dart' as http;

import '../../../data/api_services.dart';
import '../../../data/status.dart';
import '../../theme/resource/strings_constants.dart';
import '../../widgets/custom_snackbar.dart';

ApiService _apiService = ApiService();

class TripController extends GetxController {
  RxBool isLoading = false.obs;

  setLoading() => isLoading.value = !isLoading.value;

  Rx<Address> pickupAddress = Address().obs;
  Rx<Address> destinationAddress = Address().obs;

  Future addTrip() async {
    setLoading();
    try {
      /*   var response = await _apiService.;
    if (response != null &&
    response.data[StringConstants.status] == Status.success.name) {}
    else {
    CustomSnackBar.showSnackBar(CustomSnackBar.error,
    response?.data[StringConstants.message], CustomSnackBar.error);
    }*/
    } finally {
      setLoading();
    }
  }

  Future getDistanceByRoad() async {

    var lat1 = pickupAddress.value.position!.coordinates![0].toString();
    var lon1 = pickupAddress.value.position!.coordinates![1].toString();
    var lat2 = destinationAddress.value.position!.coordinates![0].toString();
    var lon2 = destinationAddress.value.position!.coordinates![1].toString();
    var url =
        "https://maps.googleapis.com/maps/api/directions/json?origin=$lat1,$lon1&destination=$lat2,$lon2&sensor=false&units=metric&mode=driving&key=AIzaSyCO5CDU2-xVi6VRy14HhptZ3A8Bztx5Ps4";

    try {
      final response = await _apiService.post(url, {}, customBaseURI: true);
      //final json = jsonDecode(response.body);
/*
      if (json["status"] == "OK") {
        final routes = json["routes"][0];
        final legs = routes["legs"][0];
        final distanceText = legs["distance"]["text"];
        return distanceText;
      } else {
        return "Failed to get distance";
      }*/
    } catch (e) {
      return "Error: ${e.toString()}";
    }
  }

/*  Future<String> getDistanceByRoad() async {
    setLoading();
    var lat1 = pickupAddress.value.position!.coordinates![0];
    var lon1 = pickupAddress.value.position!.coordinates![1];
    var lat2 = destinationAddress.value.position!.coordinates![1];
    var lon2 = destinationAddress.value.position!.coordinates![1];
    var url = "https://maps.googleapis.com/maps/api/directions/json?origin=$lat1,$lon1&destination=$lat2,$lon2&sensor=false&units=metric&mode=driving&key=AIzaSyCO5CDU2-xVi6VRy14HhptZ3A8Bztx5Ps4";

    try {
     */ /* var dio = Dio();
      var response = await dio.post(url);*/ /*
      final response = await _apiService.post(url,{}, customBaseURI: true);
      setLoading();
      if (response != null && response.statusCode == 200) {
        final json = jsonDecode(response.data);

        if (json["status"] == "OK") {
          final routes = json["routes"][0];
          final legs = routes["legs"][0];
          final distanceText = legs["distance"]["text"];
          return distanceText;
        } else {
          return "Failed to get distance";
        }
      } else {
        return "Error: ${response?.statusCode}";
      }
    } catch (e) {
      return "Error: ${e.toString()}";
    }
  }*/
}
