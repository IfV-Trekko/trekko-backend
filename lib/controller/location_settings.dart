import 'dart:io';

import 'package:app_backend/model/profile/battery_usage_setting.dart';
import 'package:geolocator/geolocator.dart';

LocationSettings getSettings(BatteryUsageSetting setting) {
  late LocationSettings locationSettings;

  if (Platform.isAndroid) {
    locationSettings = AndroidSettings(
        accuracy: setting.accuracy,
        distanceFilter: 10,
        forceLocationManager: true,
        intervalDuration: const Duration(seconds: 10),
        foregroundNotificationConfig: const ForegroundNotificationConfig(
          notificationText: "Tracking your location... Better run!",
          notificationTitle: "Trekko",
          enableWakeLock: true,
        ));
  } else if (Platform.isIOS || Platform.isMacOS) {
    locationSettings = AppleSettings(
      accuracy: setting.accuracy,
      activityType: ActivityType.airborne,
      distanceFilter: 10,
      pauseLocationUpdatesAutomatically: true,
      showBackgroundLocationIndicator: true,
    );
  } else {
    locationSettings = LocationSettings(
      accuracy: setting.accuracy,
      distanceFilter: 10,
    );
  }

  return locationSettings;
}
