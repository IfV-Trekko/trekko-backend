import 'dart:convert';

import 'package:isar/isar.dart';
import 'package:trekko_backend/model/tracking/cache/raw_phone_data_type.dart';

part 'cache_object.g.dart';

@collection
class CacheObject {
  Id id = Isar.autoIncrement;
  int timestamp;
  @enumerated
  RawPhoneDataType type;
  String value;

  CacheObject(this.type, this.value, this.timestamp);

  factory CacheObject.fromJson(Map<String, dynamic> json) {
    return CacheObject(json['type'], jsonEncode(json), json['time']);
  }

  Map<String, dynamic> toJson() => {
        'type': type,
        'value': value,
        'timestamp': timestamp,
      };
}
