import 'package:trekko_backend/model/position.dart';
import 'package:isar/isar.dart';

part 'tracked_point.g.dart';

@embedded
class TrackedPoint {
  double latitude;
  double longitude;
  DateTime timestamp;

  /// Creates a tracked point with the given data
  TrackedPoint.withData(
      this.latitude, this.longitude, this.timestamp);

  /// Creates a tracked point with no data
  TrackedPoint()
      : latitude = 0,
        longitude = 0,
        timestamp = DateTime.now();

  /// Creates a new tracked point from the given position
  TrackedPoint.fromPosition(Position position)
      : latitude = position.latitude,
        longitude = position.longitude,
        timestamp = position.timestamp;

  /// Returns the position of the tracked point
  Position toPosition() {
    return Position(
      latitude: latitude,
      longitude: longitude,
      timestamp: timestamp,
      accuracy: 0,
      altitude: 0,
      altitudeAccuracy: 0,
      heading: 0,
      headingAccuracy: 0,
      speedAccuracy: 0,
      speed: 0,
    );
  }
}
