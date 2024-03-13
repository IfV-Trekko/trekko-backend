import 'package:background_locator_2/location_dto.dart';
import 'package:json_annotation/json_annotation.dart';

part 'position.g.dart';

@JsonSerializable()
class Position {
  @JsonKey(name: "latitude")
  final double latitude;
  @JsonKey(name: "longitude")
  final double longitude;
  @JsonKey(name: "time", toJson: _dateTimeToJson, fromJson: _dateTimeFromJson)
  final DateTime timestamp;
  @JsonKey(name: "accuracy")
  final double accuracy;
  @JsonKey(name: "altitude")
  final double altitude;
  @JsonKey(name: "altitude_accuracy")
  final double? altitudeAccuracy;
  @JsonKey(name: "heading")
  final double heading;
  @JsonKey(name: "heading_accuracy")
  final double? headingAccuracy;
  @JsonKey(name: "speed")
  final double speed;
  @JsonKey(name: "speed_accuracy")
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

  factory Position.fromLocationDto(LocationDto locationDto) {
    return _$PositionFromJson(locationDto.toJson());
  }

  LocationDto toLocationDto() {
    return LocationDto.fromJson(_$PositionToJson(this));
  }

  static DateTime _dateTimeFromJson(double value) {
    return DateTime.fromMillisecondsSinceEpoch(value.toInt());
  }

  static double _dateTimeToJson(DateTime value) {
    return value.millisecondsSinceEpoch.toDouble();
  }
}
