import 'package:trekko_backend/model/position.dart';
import 'package:trekko_backend/model/profile/battery_usage_setting.dart';

abstract class Tracking {

  Future<void> init();

  Future<bool> isRunning();

  Stream<Position> track(BatteryUsageSetting setting);

  Future<void> clearCache();

  Future<List<Position>> clearAndReadCache();

  Future<void> stop();

}