import 'package:permission_handler/permission_handler.dart';
import 'package:trekko_backend/model/position.dart';
import 'package:trekko_backend/model/profile/battery_usage_setting.dart';

abstract class Tracking {

  static final List<Permission> perms = [
    Permission.locationWhenInUse,
    Permission.locationAlways,
    Permission.notification
  ];

  Future<void> init(BatteryUsageSetting setting);

  Future<bool> isRunning();

  Stream<Position> track();

  Future<bool> start();

  Future<void> stop();

  Future<void> clearCache();

  bool isProcessing();

}