import 'package:isar/isar.dart';

part 'cache_object.g.dart';

@collection
class CacheObject {
  Id id = Isar.autoIncrement;
  String value;

  CacheObject(this.value);
}