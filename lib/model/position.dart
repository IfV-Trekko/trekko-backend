import 'package:background_locator_2/location_dto.dart';
import 'package:json_annotation/json_annotation.dart';

part 'position.g.dart';

@JsonSerializable()
class Position {
  @JsonKey(name: "latitude")
  final double latitude;
  @JsonKey(name: "longitude")
  final double longitude;
  @JsonKey(name: "timestamp")
  final DateTime timestamp;
  @JsonKey(name: "accuracy")
  final double accuracy;
  @JsonKey(name: "altitude")
  final double altitude;
  @JsonKey(name: "altitudeAccuracy")
  final double altitudeAccuracy;
  @JsonKey(name: "heading")
  final double heading;
  @JsonKey(name: "headingAccuracy")
  final double headingAccuracy;
  @JsonKey(name: "speed")
  final double speed;
  @JsonKey(name: "speedAccuracy")
  final double speedAccuracy;

  Position({
    required this.latitude,
    required this.longitude,
    required this.timestamp,
    required this.accuracy,
    required this.altitude,
    required this.altitudeAccuracy,
    required this.heading,
    required this.headingAccuracy,
    required this.speed,
    required this.speedAccuracy,
  });

  Position.fromLocationDto(LocationDto locationDto)
      : latitude = locationDto.latitude,
        longitude = locationDto.longitude,
        timestamp = DateTime.fromMillisecondsSinceEpoch(locationDto.time.round()),
        accuracy = locationDto.accuracy,
        altitude = locationDto.altitude,
        altitudeAccuracy = 0,
        heading = locationDto.heading,
        headingAccuracy = 0,
        speed = locationDto.speed,
        speedAccuracy = locationDto.speedAccuracy;

  LocationDto toLocationDto() {
    return LocationDto.fromJson(_$PositionToJson(this));
  }
}