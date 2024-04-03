import 'package:json_annotation/json_annotation.dart';
import 'package:geolocator/geolocator.dart' as geo;

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

  factory Position.fromGeoPosition(geo.Position position) {
    return Position(
      latitude: position.latitude,
      longitude: position.longitude,
      timestamp: position.timestamp,
      accuracy: position.accuracy,
      altitude: position.altitude,
      altitudeAccuracy: position.altitudeAccuracy,
      heading: position.heading,
      headingAccuracy: position.headingAccuracy,
      speed: position.speed,
      speedAccuracy: position.speedAccuracy,
    );
  }

  factory Position.fromJson(dynamic json) => _$PositionFromJson(json);

  Map<String, dynamic> toJson() => _$PositionToJson(this);

  static DateTime _dateTimeFromJson(int value) {
    return DateTime.fromMillisecondsSinceEpoch(value);
  }

  static int _dateTimeToJson(DateTime value) {
    return value.millisecondsSinceEpoch.toInt();
  }
}
