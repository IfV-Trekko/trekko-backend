import 'package:geolocator/geolocator.dart';
import 'package:isar/isar.dart';

part 'tracked_point.g.dart';

@embedded
class TrackedPoint {
  double latitude; // TODO: final
  double longitude;
  double speed_in_kmh;
  DateTime timestamp;

  /// Creates a tracked point with the given data
  TrackedPoint.withData(
      this.latitude, this.longitude, this.speed_in_kmh, this.timestamp);

  /// Creates a tracked point with no data
  TrackedPoint()
      : latitude = 0,
        longitude = 0,
        speed_in_kmh = 0,
        timestamp = DateTime.now();

  /// Creates a new tracked point from the given position
  TrackedPoint.fromPosition(Position position)
      : latitude = position.latitude,
        longitude = position.longitude,
        speed_in_kmh = position.speed,
        timestamp = position.timestamp;

  /// Returns the position of the tracked point
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
