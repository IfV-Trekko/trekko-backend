import 'package:json_annotation/json_annotation.dart';
import 'package:trekko_backend/model/tracking/cache/raw_phone_data_type.dart';
import 'package:trekko_backend/model/tracking/raw_phone_data.dart';

part 'position.g.dart';

@JsonSerializable()
class Position implements RawPhoneData {

  @JsonKey(name: "latitude")
  final double latitude;

  @JsonKey(name: "longitude")
  final double longitude;

  @JsonKey(name: "time", toJson: _dateTimeToJson, fromJson: _dateTimeFromJson)
  final DateTime timestamp;

  @JsonKey(name: "accuracy")
  final double accuracy;

  @JsonKey(name: RawPhoneDataType.type_loc, toJson: RawPhoneDataType.toJson, includeFromJson: false, includeToJson: true)
  final RawPhoneDataType type = RawPhoneDataType.position;

  Position(
      {required this.latitude,
      required this.longitude,
      required this.timestamp,
      required this.accuracy});

  factory Position.fromJson(dynamic json) => _$PositionFromJson(json);

  Map<String, dynamic> toJson() => _$PositionToJson(this);

  static DateTime _dateTimeFromJson(int value) {
    return DateTime.fromMillisecondsSinceEpoch(value);
  }

  static int _dateTimeToJson(DateTime value) {
    return value.millisecondsSinceEpoch.toInt();
  }

  @override
  DateTime getTimestamp() {
    return this.timestamp;
  }

  @override
  RawPhoneDataType getType() {
    return type;
  }
}
