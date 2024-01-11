import 'package:geolocator/geolocator.dart';
import 'package:isar/isar.dart';

part 'tracked_point.g.dart';

@embedded
class TrackedPoint {
  final double latitude;
  final double longitude;
  final double speed_in_kmh;
  final DateTime timestamp;

  TrackedPoint.fromPosition(Position position)
      : latitude = position.latitude,
        longitude = position.longitude,
        speed_in_kmh = position.speed,
        timestamp = position.timestamp;

  TrackedPoint()
      : latitude = 0,
        longitude = 0,
        speed_in_kmh = 0,
        timestamp = DateTime.now();

  Position toPosition() {
    return Position(
      latitude: latitude,
      longitude: longitude,
      speed: speed_in_kmh,
      timestamp: timestamp,
      accuracy: 0,
      altitude: 0,
      altitudeAccuracy: 0,
      heading: 0,
      headingAccuracy: 0,
      speedAccuracy: 0,
    );
  }
}
