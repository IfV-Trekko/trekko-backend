import 'package:json_annotation/json_annotation.dart';
import 'package:trekko_backend/controller/utils/serialize_utils.dart';
import 'package:trekko_backend/model/tracking/cache/raw_phone_data_type.dart';
import 'package:trekko_backend/model/tracking/raw_phone_data.dart';

part 'accelerometer_data.g.dart';

@JsonSerializable()
class AccelerometerData extends RawPhoneData {
  @JsonKey(name: "x")
  final double x;

  @JsonKey(name: "y")
  final double y;

  @JsonKey(name: "z")
  final double z;

  @JsonKey(name: "time", toJson: dateTimeToJson, fromJson: dateTimeFromJson)
  final DateTime timestamp;

  @JsonKey(name: RawPhoneDataType.type_loc, toJson: RawPhoneDataType.toJson, includeFromJson: false, includeToJson: true)
  final RawPhoneDataType type = RawPhoneDataType.accelerometer;

  AccelerometerData(
      {required this.x, required this.y, required this.z, required this.timestamp});

  factory AccelerometerData.fromJson(dynamic json) => _$AccelerometerDataFromJson(json);

  Map<String, dynamic> toJson() => _$AccelerometerDataToJson(this);

  @override
  DateTime getTimestamp() {
    return this.timestamp;
  }

  @override
  RawPhoneDataType getType() {
    return type;
  }
}