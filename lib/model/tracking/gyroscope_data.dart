import 'package:json_annotation/json_annotation.dart';
import 'package:trekko_backend/model/tracking/cache/raw_phone_data_type.dart';
import 'package:trekko_backend/model/tracking/raw_phone_data.dart';

part 'gyroscope_data.g.dart';

@JsonSerializable()
class GyroscopeData implements RawPhoneData {

  @JsonKey(name: "x")
  final double x;

  @JsonKey(name: "y")
  final double y;

  @JsonKey(name: "z")
  final double z;

  @JsonKey(name: "time", toJson: _dateTimeToJson, fromJson: _dateTimeFromJson)
  final DateTime timestamp;

  @JsonKey(name: RawPhoneDataType.type_loc, toJson: RawPhoneDataType.toJson, includeFromJson: false, includeToJson: true)
  final RawPhoneDataType type = RawPhoneDataType.gyroscope;

  GyroscopeData(
      {required this.x, required this.y, required this.z, required this.timestamp});

  factory GyroscopeData.fromJson(dynamic json) => _$GyroscopeDataFromJson(json);

  Map<String, dynamic> toJson() => _$GyroscopeDataToJson(this);

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