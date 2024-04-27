import 'package:isar/isar.dart';
import 'package:trekko_backend/model/log/log_level.dart';

part 'log_entry.g.dart';

@collection
class LogEntry {

  Id id = Isar.autoIncrement;
  @enumerated
  LogLevel level;
  String message;
  DateTime timestamp;

  LogEntry(this.level, this.message, this.timestamp);

}