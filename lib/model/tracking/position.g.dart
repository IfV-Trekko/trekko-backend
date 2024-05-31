// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'position.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Position _$PositionFromJson(Map<String, dynamic> json) => Position(
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      timestamp: Position._dateTimeFromJson((json['time'] as num).toInt()),
      accuracy: (json['accuracy'] as num).toDouble(),
    );

Map<String, dynamic> _$PositionToJson(Position instance) => <String, dynamic>{
      'latitude': instance.latitude,
      'longitude': instance.longitude,
      'time': Position._dateTimeToJson(instance.timestamp),
      'accuracy': instance.accuracy,
      'type': RawPhoneDataType.toJson(instance.type),
    };
