import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_places_flutter/google_places_flutter.dart';
import 'package:google_places_flutter/model/prediction.dart';

import '../../theme/resource/strings_constants.dart';
import 'address_controller.dart';
import 'map_location_controller.dart';

class LocationFromMap extends StatefulWidget {
  const LocationFromMap({super.key});

  @override
  State<LocationFromMap> createState() => _LocationFromMapState();
}

class _LocationFromMapState extends State<LocationFromMap> {
  GoogleMapController? googleMapController;
  TextEditingController textEditingController = TextEditingController();
  AddressController addressController = Get.find();
  MapLocationController mapLocationController = Get.find();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text('Select address from map'),
      ),
      body: Obx(() => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: GoogleMap(
                        mapType: MapType.normal,
                        onMapCreated: (GoogleMapController controller) {
                          googleMapController = controller;
                          setLocation(mapLocationController.lat.value,
                              mapLocationController.lng.value);
                        },
                        initialCameraPosition: CameraPosition(
                          target: LatLng(addressController.lat.value,
                              addressController.lng.value),
                          zoom: 12.0,
                        ),
                        markers: {
                          Marker(
                              markerId: const MarkerId(
                                  'marker_1'), // Unique ID for the marker
                              position: LatLng(
                                  addressController.lat.value,
                                  addressController
                                      .lng.value), // Position of the marker
                              icon: BitmapDescriptor.defaultMarkerWithHue(
                                  BitmapDescriptor.hueRed),
                              onTap: null),
                        },
                        onTap: (position) async {
                          setLocation(position.latitude, position.longitude);
                        },
                      ),
                    ),
                    Positioned(
                      top: 15,
                      left: 10,
                      right: 10,
                      child: GooglePlaceAutoCompleteTextField(
                        textStyle: Theme.of(context).textTheme.titleSmall!,
                        isCrossBtnShown: false,
                        boxDecoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius:
                              const BorderRadius.all(Radius.circular(5)),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.shade400, // Shadow color
                              offset:
                                  const Offset(0, 3), // Offset of the shadow
                              blurRadius: 6, // Spread of the shadow
                            ),
                          ],
                        ),
                        textEditingController: textEditingController,
                        googleAPIKey: StringConstants.googleMapsKey,

                        inputDecoration: InputDecoration(
                            enabledBorder: OutlineInputBorder(
                                borderSide:
                                    BorderSide(color: Colors.grey.shade300)),
                            hintText: 'Serach city, address, etc. here',
                            filled: true,
                            fillColor: Colors.grey.shade200),
                        debounceTime: 200, // default 600 ms,
                        countries: const [
                          "in"
                        ], // optional by default null is set
                        isLatLngRequired:
                            true, // if you required coordinates from place detail
                        getPlaceDetailWithLatLng: (Prediction prediction) {
                          setLocation(double.parse(prediction.lat.toString()),
                              double.parse(prediction.lng.toString()));
                        }, // this callback is called when isLatLngRequired is true
                        itemClick: (Prediction prediction) {
                          textEditingController.text =
                              prediction.description ?? '';
                          textEditingController.selection =
                              TextSelection.fromPosition(TextPosition(
                                  offset: prediction.description!.length));
                        },
                        // if we want to make custom list item builder
                        itemBuilder: (context, index, Prediction prediction) {
                          return Container(
                            padding: const EdgeInsets.all(10),
                            child: Row(
                              children: [
                                const Icon(Icons.location_on),
                                const SizedBox(
                                  width: 7,
                                ),
                                Expanded(
                                    child: Text(prediction.description ?? ""))
                              ],
                            ),
                          );
                        },
                        // if you want to add seperator between list items
                        seperatedBuilder: const Divider(),
                      ),
                    )
                  ],
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              Align(
                alignment: Alignment.center,
                child: Text('Search, Drag and tap to select location on map.',
                    style: Theme.of(context).textTheme.bodySmall),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: ElevatedButton(
                  onPressed: mapLocationController.isLoading.isTrue
                      ? null
                      : () {
                          Get.back(result: true);
                        },
                  child: const Text('Confirm location'),
                ),
              ),
            ],
          )),
    );
  }

  Future<void> setLocation(double lat, double lng) async {
    await googleMapController!.animateCamera(CameraUpdate.newCameraPosition(
        CameraPosition(target: LatLng(lat, lng), zoom: 16.0)));
    addressController.lat.value = lat;
    addressController.lng.value = lng;
    Placemark placemark =
        await mapLocationController.getAdderessFromLatLng(lat, lng);
    textEditingController.text =
        '${placemark.name}, ${placemark.locality}, ${placemark.postalCode}';
  }
}
