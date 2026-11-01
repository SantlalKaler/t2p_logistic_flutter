import 'package:geolocator/geolocator.dart';

/// Preserve the tap time offline. A recent recorded fix is optional: stopping
/// must never depend on GPS or a new location permission prompt.
Map<String, dynamic> dutyStopRequest({
  required String sessionId,
  required DateTime tappedAt,
  Position? lastPosition,
}) {
  final body = <String, dynamic>{
    'session_id': sessionId,
    'at': tappedAt.toUtc().toIso8601String(),
  };
  final p = lastPosition;
  if (p == null) return body;
  final age = tappedAt.difference(p.timestamp);
  if (age.isNegative ||
      age > const Duration(seconds: 60) ||
      !p.latitude.isFinite ||
      !p.longitude.isFinite ||
      p.latitude.abs() > 90 ||
      p.longitude.abs() > 180 ||
      !p.accuracy.isFinite ||
      p.accuracy < 0 ||
      p.accuracy > 100) {
    return body;
  }
  body.addAll({'lat': p.latitude, 'lng': p.longitude, 'accuracy': p.accuracy});
  return body;
}
