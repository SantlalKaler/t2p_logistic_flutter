import 'package:geolocator/geolocator.dart';

/// Compare against the last SAVED fix; never filter the native GPS stream.
bool shouldSaveDutyPoint(Position location, Position? lastSaved) =>
    lastSaved == null ||
    location.timestamp.difference(lastSaved.timestamp) >=
        const Duration(seconds: 30) ||
    Geolocator.distanceBetween(
          lastSaved.latitude,
          lastSaved.longitude,
          location.latitude,
          location.longitude,
        ) >=
        30;
