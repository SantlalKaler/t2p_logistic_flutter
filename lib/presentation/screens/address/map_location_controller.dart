import 'package:flutter/foundation.dart';
import 'package:geocoding/geocoding.dart';
import 'package:get/get.dart';

class MapLocationController extends GetxController {
  RxBool isLoading = false.obs;
  RxDouble lat = 28.6139.obs; // Delhi
  RxDouble lng = 77.2090.obs; // Delhi

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
      List<Location> locations =
          await locationFromAddress(address);
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

  // Future<Position> getCurrentLocation() async {
  //   isLoading.value = true;
  //   isGettingCurrentLocation.value = true;
  //   CustomSnackBar.showSnackBar(CustomSnackBar.success,
  //       'Fetching your current location...', CustomSnackBar.success);

  //   try {
  //     Position position = await Geolocator.getCurrentPosition();
  //     return position;
  //   } finally {
  //     isGettingCurrentLocation.value = false;
  //     isLoading.value = false;
  //   }
  // }
}
