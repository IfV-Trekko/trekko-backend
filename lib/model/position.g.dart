// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'position.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Position _$PositionFromJson(Map<String, dynamic> json) => Position(
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      timestamp: Position._dateTimeFromJson((json['time']).toInt()),
      accuracy: (json['accuracy'] as num?)?.toDouble(),
      altitude: (json['altitude'] as num?)?.toDouble(),
      altitudeAccuracy: (json['altitude_accuracy'] as num?)?.toDouble(),
      heading: (json['heading'] as num?)?.toDouble(),
      headingAccuracy: (json['heading_accuracy'] as num?)?.toDouble(),
      speed: (json['speed'] as num?)?.toDouble(),
      speedAccuracy: (json['speed_accuracy'] as num?)?.toDouble(),
    );

Map<String, dynamic> _$PositionToJson(Position instance) => <String, dynamic>{
      'latitude': instance.latitude,
      'longitude': instance.longitude,
      'time': Position._dateTimeToJson(instance.timestamp),
      'accuracy': instance.accuracy,
      'altitude': instance.altitude,
      'altitude_accuracy': instance.altitudeAccuracy,
      'heading': instance.heading,
      'heading_accuracy': instance.headingAccuracy,
      'speed': instance.speed,
      'speed_accuracy': instance.speedAccuracy,
    };
