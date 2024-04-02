import 'package:isar/isar.dart';

part 'cache_object.g.dart';

@collection
class CacheObject {
  Id id = Isar.autoIncrement;
  int timestamp;
  String value;

  CacheObject(this.value, this.timestamp);

  factory CacheObject.fromJson(Map<String, dynamic> json) {
    return CacheObject(json['value'], json['timestamp']);
  }

  Map<String, dynamic> toJson() => {
    'value': value,
    'timestamp': timestamp,
  };
}