import 'package:isar/isar.dart';
import 'package:trekko_backend/model/cache/wrapper_type.dart';

part 'analyzer_cache.g.dart';

@collection
class AnalyzerCache {
  Id id = Isar.autoIncrement;
  @enumerated
  @Index(unique: true, replace: true)
  WrapperType type;
  String value;

  AnalyzerCache(this.type, this.value);
}
