import 'package:flutter_activity_recognition/models/activity_confidence.dart';
import 'package:flutter_activity_recognition/models/activity_type.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:trekko_backend/controller/utils/serialize_utils.dart';
import 'package:trekko_backend/model/tracking/cache/raw_phone_data_type.dart';
import 'package:trekko_backend/model/tracking/raw_phone_data.dart';

part 'activity_data.g.dart';

@JsonSerializable()
class ActivityData implements RawPhoneData {
  @JsonKey(name: "activityType")
  final ActivityType activity;

  @JsonKey(name: "time", toJson: dateTimeToJson, fromJson: dateTimeFromJson)
  final DateTime timestamp;

  @JsonKey(name: "confidence")
  final ActivityConfidence confidence;

  @JsonKey(
      name: RawPhoneDataType.type_loc,
      toJson: RawPhoneDataType.toJson,
      includeFromJson: false,
      includeToJson: true)
  final RawPhoneDataType type = RawPhoneDataType.activity;

  ActivityData(
      {required this.timestamp,
      required this.confidence,
      required this.activity});

  factory ActivityData.fromJson(dynamic json) => _$ActivityDataFromJson(json);

  @override
  DateTime getTimestamp() {
    return timestamp;
  }

  @override
  RawPhoneDataType getType() {
    return RawPhoneDataType.activity;
  }

  @override
  Map<String, dynamic> toJson() {
    return _$ActivityDataToJson(this);
  }
}
