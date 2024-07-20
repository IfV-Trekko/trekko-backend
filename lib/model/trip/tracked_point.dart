import 'package:json_annotation/json_annotation.dart';
import 'package:trekko_backend/model/tracking/position.dart';
import 'package:isar/isar.dart';

part 'tracked_point.g.dart';

@JsonSerializable()
@embedded
class TrackedPoint {
  @JsonKey(name: 'latitude')
  double latitude;
  @JsonKey(name: 'longitude')
  double longitude;
  @JsonKey(name: 'timestamp')
  DateTime timestamp;

  /// Creates a tracked point with the given data
  TrackedPoint.withData(this.latitude, this.longitude, this.timestamp);

  /// Creates a tracked point with no data
  TrackedPoint()
      : latitude = 0,
        longitude = 0,
        timestamp = DateTime.now();

  factory TrackedPoint.fromJson(Map<String, dynamic> json) =>
      _$TrackedPointFromJson(json);

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
        accuracy: 0);
  }

  Map<String, dynamic> toJson() => _$TrackedPointToJson(this);

  @override
  bool operator ==(Object other) {
    if (other is TrackedPoint) {
      return this.latitude == other.latitude &&
          this.longitude == other.longitude &&
          this.timestamp == other.timestamp;
    }
    return false;
  }

  @override
  int get hashCode {
    return Object.hash(latitude, longitude, timestamp);
  }
}
