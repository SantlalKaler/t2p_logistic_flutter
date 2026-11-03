import 'package:flutter_test/flutter_test.dart';
import 'package:geolocator/geolocator.dart';
import 'package:t2p_logistic/data/duty_recording.dart';

void main() {
  final start = DateTime.utc(2026, 11, 3);
  Position point(int seconds, {double lat = 25}) => Position(
    longitude: 85,
    latitude: lat,
    timestamp: start.add(Duration(seconds: seconds)),
    accuracy: 150,
    altitude: 0,
    altitudeAccuracy: 0,
    heading: 0,
    headingAccuracy: 0,
    speed: 0,
    speedAccuracy: 0,
  );
  test('stationary policy saves ten points in five minutes without filtering accuracy', () {
    Position? lastSaved = point(0);
    final saved = <Position>[];
    for (var second = 10; second <= 300; second += 10) {
      final fix = point(second);
      if (shouldSaveDutyPoint(fix, lastSaved)) {
        saved.add(fix);
        lastSaved = fix;
      }
    }
    expect(saved.length, 10);
    expect(saved.every((p) => p.accuracy == 150), isTrue);
    expect(saved.first.timestamp, start.add(const Duration(seconds: 30)));
  });
  test(
    'movement between 30 and 50 metres records immediately; smaller moves wait',
    () {
      expect(shouldSaveDutyPoint(point(5, lat: 25.0003), point(0)), isTrue);
      expect(shouldSaveDutyPoint(point(10, lat: 25.0001), point(0)), isFalse);
      expect(shouldSaveDutyPoint(point(30, lat: 25.0001), point(0)), isTrue);
      expect(shouldSaveDutyPoint(point(0), null), isTrue);
    },
  );
}
