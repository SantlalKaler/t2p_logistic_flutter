import 'dart:convert';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:t2p_logistic/data/api_services.dart';
import 'package:t2p_logistic/presentation/controllers/user_controller.dart';
import 'package:t2p_logistic/presentation/theme/resource/custom_constants.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../domain/Model/location_logging.dart';
import '../../widgets/custom_snackbar.dart';
import '../permission_handler.dart';

class MapLocationController extends GetxController {
  RxBool isLoading = false.obs;
  RxDouble lat = 28.6139.obs; // Delhi
  RxDouble lng = 77.2090.obs; // Delhi
  final ApiService _apiService = ApiService();

  Future<Placemark> getAdderessFromLatLng(double lat, double lng) async {
    isLoading.value = true;
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(lat, lng);
      if (kDebugMode) {
        print('--------ADDRESS FROM CORDINATES BELLOW--------');
        print(placemarks[0]);
      }
      return placemarks[0];
    } finally {
      isLoading.value = false;
    }
  }

  getCordinatesFromAddress(String address) async {
    isLoading.value = true;
    try {
      List<Location> locations = await locationFromAddress(address);
      if (kDebugMode) {
        print('--------CORDINATES FROM ADDRESS BELLOW--------');
        print(locations[0]);
      }
      lat.value = locations[0].latitude;
      lng.value = locations[0].longitude;
    } finally {
      isLoading.value = false;
    }
  }

  Future<Position> getCurrentLocation() async {
    isLoading.value = true;
    /*CustomSnackBar.showSnackBar(CustomSnackBar.success,
        'Fetching your current location...', CustomSnackBar.success);*/

    try {
      Position position = await Geolocator.getCurrentPosition();
      printValue("Current location : $position");
      return position;
    } finally {
      isLoading.value = false;
    }
  }

  Future locationAndGpsEnabled() async {
    return await isPermissionGranted(Permission.location) &&
        await Geolocator.isLocationServiceEnabled();
  }

  Future sendLocationToFirebase() async {
    UserController userController = Get.find();
    var position = await getCurrentLocation();
    var orderId = userController.orderId;

    DatabaseReference databaseReference = FirebaseDatabase.instance.ref();

    LocationLogging locationLogging = LocationLogging(
      orderId ?? "",
      position.latitude,
      position.longitude,
      DateTime.now().millisecondsSinceEpoch,
    );

    databaseReference
        .child("userlocation$orderId")
        .set(locationLogging.toJson());
  }

  Future<String> getDistanceByRoad(
    double startLat,
    double startLng,
    double endLat,
    double endLng,
  ) async {
    var distance = "0.0";
    var url =
        "https://maps.googleapis.com/maps/api/directions/json?origin=$startLat,$startLng&destination=$endLat,$endLng&sensor=false&units=metric&mode=driving&key=AIzaSyCO5CDU2-xVi6VRy14HhptZ3A8Bztx5Ps4";

    try {
      final response = await _apiService.post(url, {}, customBaseURI: true);

      if (response != null) {
        final json = jsonDecode(response.data);
        if (json["status"] == "OK") {
          final routes = json["routes"][0];
          final legs = routes["legs"][0];
          final distanceText = legs["distance"]["text"];
          distance = distanceText;
        }
      }
    } catch (e) {
      printValue("Error to calculate distance: $e");
    }
    return distance;
  }

  void openGoogleMap(double latitude, double longitude) async {
    String googleMapsUrl =
        'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude';

    if (await launchUrl(Uri.parse(googleMapsUrl))) {
      await launchUrl(
        Uri.parse(googleMapsUrl),
        mode: LaunchMode.externalApplication,
      );
    } else {
      throw 'Could not open the map.';
    }
  }
}
