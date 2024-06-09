// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'gyroscope_data.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GyroscopeData _$GyroscopeDataFromJson(Map<String, dynamic> json) =>
    GyroscopeData(
      x: (json['x'] as num).toDouble(),
      y: (json['y'] as num).toDouble(),
      z: (json['z'] as num).toDouble(),
      timestamp: dateTimeFromJson((json['time'] as num).toInt()),
    );

Map<String, dynamic> _$GyroscopeDataToJson(GyroscopeData instance) =>
    <String, dynamic>{
      'x': instance.x,
      'y': instance.y,
      'z': instance.z,
      'time': dateTimeToJson(instance.timestamp),
      'type': RawPhoneDataType.toJson(instance.type),
    };
