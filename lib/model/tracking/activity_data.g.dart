// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'activity_data.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ActivityData _$ActivityDataFromJson(Map<String, dynamic> json) => ActivityData(
      timestamp: dateTimeFromJson((json['time'] as num).toInt()),
      confidence: $enumDecode(_$ActivityConfidenceEnumMap, json['confidence']),
      activity: $enumDecode(_$ActivityTypeEnumMap, json['type']),
    );

Map<String, dynamic> _$ActivityDataToJson(ActivityData instance) =>
    <String, dynamic>{
      'type': _$ActivityTypeEnumMap[instance.activity]!,
      'time': dateTimeToJson(instance.timestamp),
      'confidence': _$ActivityConfidenceEnumMap[instance.confidence]!,
    };

const _$ActivityConfidenceEnumMap = {
  ActivityConfidence.HIGH: 'HIGH',
  ActivityConfidence.MEDIUM: 'MEDIUM',
  ActivityConfidence.LOW: 'LOW',
};

const _$ActivityTypeEnumMap = {
  ActivityType.IN_VEHICLE: 'IN_VEHICLE',
  ActivityType.ON_BICYCLE: 'ON_BICYCLE',
  ActivityType.RUNNING: 'RUNNING',
  ActivityType.STILL: 'STILL',
  ActivityType.WALKING: 'WALKING',
  ActivityType.UNKNOWN: 'UNKNOWN',
};
