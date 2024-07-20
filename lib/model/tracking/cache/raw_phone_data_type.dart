import 'package:trekko_backend/model/tracking/accelerometer_data.dart';
import 'package:trekko_backend/model/tracking/activity_data.dart';
import 'package:trekko_backend/model/tracking/gyroscope_data.dart';
import 'package:trekko_backend/model/tracking/position.dart';
import 'package:trekko_backend/model/tracking/raw_phone_data.dart';

enum RawPhoneDataType {

  position._("position", Position.fromJson),
  gyroscope._("gyroscope", GyroscopeData.fromJson),
  accelerometer._("accelerometer", AccelerometerData.fromJson),
  activity._("activity", ActivityData.fromJson);

  static const String type_loc = "type";

  final String name;
  final RawPhoneData Function(dynamic) constructor;

  const RawPhoneDataType._(this.name, this.constructor);

  static RawPhoneData parseData(dynamic json) {
    RawPhoneDataType type = RawPhoneDataType.fromJson(json[type_loc]);
    return type.constructor(json);
  }

  static RawPhoneDataType fromJson(String type) {
    for (RawPhoneDataType t in RawPhoneDataType.values) {
      if (t.name == type) {
        return t;
      }
    }
    throw Exception("Unknown type: $type");
  }

  static String toJson(RawPhoneDataType type) {
    return type.name;
  }
}