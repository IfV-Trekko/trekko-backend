import 'package:permission_handler/permission_handler.dart';
import 'package:trekko_backend/model/position.dart';
import 'package:trekko_backend/model/profile/battery_usage_setting.dart';

abstract class Tracking {

  static final List<Permission> perms = [
    Permission.locationWhenInUse,
    Permission.locationAlways,
    Permission.notification,
    Permission.ignoreBatteryOptimizations
  ];

  Future init(BatteryUsageSetting options);

  Future<bool> isRunning();

  Future<bool> start(BatteryUsageSetting setting, Future Function(Position) callback);

  Future stop();

  bool isProcessing();

}