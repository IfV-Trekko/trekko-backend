import 'package:isar/isar.dart';
import 'package:trekko_backend/controller/utils/database_utils.dart';
import 'package:trekko_backend/model/log/log_entry.dart';
import 'package:trekko_backend/model/log/log_level.dart';

class Logging {
  static List<Function(MapEntry<LogLevel, String>)> loggingHooks = [];

  static Future<void> write(LogLevel level, String message) async {
    MapEntry<LogLevel, String> e = MapEntry(level, message);
    loggingHooks.forEach((l) => l.call(e));
    Isar _logs = await Databases.logs.getInstance();
    await _logs.writeTxn(() {
      return _logs.logEntrys.put(LogEntry(level, message, DateTime.now()));
    });
  }

  static Future<void> error(String message) async {
    await write(LogLevel.error, message);
  }

  static Future<void> errorE(Object exception, StackTrace? stack) async {
    String message = exception.toString();
    if (stack != null) {
      message += "\nStack:\n" + stack.toString();
    }
    await error(message);
  }

  static Future<void> info(String message) async {
    await write(LogLevel.info, message);
  }

  static Future<void> warning(String message) async {
    await write(LogLevel.warning, message);
  }

  static Future<Stream<List<LogEntry>>> read() async {
    Isar _logs = await Databases.logs.getInstance();
    return _logs.logEntrys
        .where()
        .sortByTimestampDesc()
        .watch(fireImmediately: true);
  }

  static Future<void> clear() async {
    Isar _logs = await Databases.logs.getInstance();
    await _logs.writeTxn(() {
      return _logs.logEntrys.where().deleteAll();
    });
  }
}
