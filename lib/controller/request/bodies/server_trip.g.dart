// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'server_trip.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ServerTrip _$ServerTripFromJson(Map<String, dynamic> json) => ServerTrip(
      json['uid'] as String,
      json['startTimestamp'] as int,
      json['endTimestamp'] as int,
      (json['distance'] as num).toDouble(),
      (json['transportTypes'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      json['purpose'] as String?,
      json['comment'] as String?,
    );

Map<String, dynamic> _$ServerTripToJson(ServerTrip instance) =>
    <String, dynamic>{
      'uid': instance.uid,
      'startTimestamp': instance.startTimestamp,
      'endTimestamp': instance.endTimestamp,
      'distance': instance.distance,
      'transportTypes': instance.transportTypes,
      'purpose': instance.purpose,
      'comment': instance.comment,
    };
