// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'accelerometer_data.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AccelerometerData _$AccelerometerDataFromJson(Map<String, dynamic> json) =>
    AccelerometerData(
      x: (json['x'] as num).toDouble(),
      y: (json['y'] as num).toDouble(),
      z: (json['z'] as num).toDouble(),
      timestamp: dateTimeFromJson((json['time'] as num).toInt()),
    );

Map<String, dynamic> _$AccelerometerDataToJson(AccelerometerData instance) =>
    <String, dynamic>{
      'x': instance.x,
      'y': instance.y,
      'z': instance.z,
      'time': dateTimeToJson(instance.timestamp),
      'type': RawPhoneDataType.toJson(instance.type),
    };
