import 'package:permission_handler/permission_handler.dart';
import 'package:trekko_backend/model/profile/battery_usage_setting.dart';
import 'package:trekko_backend/model/tracking/raw_phone_data.dart';

abstract class Tracking {
  static final List<Permission> perms = [
    Permission.locationWhenInUse,
    Permission.locationAlways,
    Permission.notification,
    Permission.ignoreBatteryOptimizations,
    Permission.activityRecognition
  ];

  Future init(BatteryUsageSetting options);

  Future<bool> isRunning();

  Future<bool> start(BatteryUsageSetting setting,
      Future Function(List<RawPhoneData>) callback);

  Future readCache();

  Future stop();

  bool isProcessing();
}
