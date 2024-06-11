import 'package:permission_handler/permission_handler.dart';
import 'package:trekko_backend/model/profile/battery_usage_setting.dart';
import 'package:trekko_backend/model/tracking/raw_phone_data.dart';

abstract class Tracking {
  static final List<Permission> perms = [
    Permission.notification,
    Permission.activityRecognition,
    Permission.ignoreBatteryOptimizations,
    Permission.locationWhenInUse,
    Permission.locationAlways,
  ];

  Future init(BatteryUsageSetting options);

  Future<bool> isRunning();

  Future<bool> start(BatteryUsageSetting setting,
      Future Function(Iterable<RawPhoneData>) callback);

  Future readCache();

  Future stop();

  bool isProcessing();
}
