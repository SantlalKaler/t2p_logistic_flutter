import 'package:flutter_test/flutter_test.dart';
import 'package:geolocator/geolocator.dart';
import 'package:t2p_logistic/data/duty_requests.dart';

void main() {
  final tap = DateTime.utc(2026, 11, 1, 10);
  Position fix({DateTime? at, double accuracy = 8, double lat = 25.62}) =>
      Position(
        longitude: 85.13,
        latitude: lat,
        timestamp: at ?? tap.subtract(const Duration(seconds: 10)),
        accuracy: accuracy,
        altitude: 0,
        altitudeAccuracy: 0,
        heading: 0,
        headingAccuracy: 0,
        speed: 0,
        speedAccuracy: 0,
      );
  test(
    'Stop includes recent endpoint coordinates and original UTC tap time',
    () {
      final body = dutyStopRequest(
        sessionId: 'session-a',
        tappedAt: tap,
        lastPosition: fix(),
      );
      expect(body, {
        'session_id': 'session-a',
        'at': '2026-11-01T10:00:00.000Z',
        'lat': 25.62,
        'lng': 85.13,
        'accuracy': 8.0,
      });
    },
  );
  test(
    'GPS unavailable, stale, inaccurate or future fixes never prevent Stop',
    () {
      for (final point in [
        null,
        fix(at: tap.subtract(const Duration(minutes: 2))),
        fix(accuracy: 101),
        fix(lat: 95),
        fix(at: tap.add(const Duration(seconds: 1))),
      ]) {
        expect(
          dutyStopRequest(
            sessionId: 'session-a',
            tappedAt: tap,
            lastPosition: point,
          ),
          {'session_id': 'session-a', 'at': '2026-11-01T10:00:00.000Z'},
        );
      }
    },
  );
}
