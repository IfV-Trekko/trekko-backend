// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'position.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Position _$PositionFromJson(Map<String, dynamic> json) => Position(
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      timestamp: DateTime.parse(json['timestamp'] as String),
      accuracy: (json['accuracy'] as num).toDouble(),
      altitude: (json['altitude'] as num).toDouble(),
      altitudeAccuracy: (json['altitudeAccuracy'] as num).toDouble(),
      heading: (json['heading'] as num).toDouble(),
      headingAccuracy: (json['headingAccuracy'] as num).toDouble(),
      speed: (json['speed'] as num).toDouble(),
      speedAccuracy: (json['speedAccuracy'] as num).toDouble(),
    );

Map<String, dynamic> _$PositionToJson(Position instance) => <String, dynamic>{
      'latitude': instance.latitude,
      'longitude': instance.longitude,
      'timestamp': instance.timestamp.toIso8601String(),
      'accuracy': instance.accuracy,
      'altitude': instance.altitude,
      'altitudeAccuracy': instance.altitudeAccuracy,
      'heading': instance.heading,
      'headingAccuracy': instance.headingAccuracy,
      'speed': instance.speed,
      'speedAccuracy': instance.speedAccuracy,
    };
