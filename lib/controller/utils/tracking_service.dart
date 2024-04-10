import 'dart:async';
import 'dart:isolate';
import 'dart:ui';

import 'package:fling_units/fling_units.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:geolocator/geolocator.dart';
import 'package:isar/isar.dart';
import 'package:trekko_backend/controller/utils/database_utils.dart';
import 'package:trekko_backend/model/cache_object.dart';
import 'package:trekko_backend/model/position.dart' as Trekko;
import 'package:trekko_backend/model/profile/battery_usage_setting.dart';
import 'package:trekko_backend/model/tracking_options.dart';

class TrackingTask extends TaskHandler {
  late StreamSubscription<Position> positionStream;

  getLocationSettings(TrackingOptions options) {
    BatteryUsageSetting batterySettings = options.batterySettings;
    int distanceFilter = batterySettings.getDistanceFilter().as(meters).toInt();
    if (defaultTargetPlatform == TargetPlatform.android) {
      return AndroidSettings(
          accuracy: batterySettings.accuracy,
          distanceFilter: distanceFilter,
          intervalDuration: batterySettings.getDuration(),
          foregroundNotificationConfig: const ForegroundNotificationConfig(
            notificationText:
                "Trekko will continue to receive your location even when you aren't using it",
            notificationTitle: "Running in Background",
            enableWakeLock: true,
          ));
    } else if (defaultTargetPlatform == TargetPlatform.iOS ||
        defaultTargetPlatform == TargetPlatform.macOS) {
      return AppleSettings(
        accuracy: batterySettings.accuracy,
        activityType: ActivityType.fitness,
        distanceFilter: distanceFilter,
        pauseLocationUpdatesAutomatically: true,
        showBackgroundLocationIndicator: true,
      );
    } else {
      return LocationSettings(
        accuracy: options.batterySettings.accuracy,
        distanceFilter: distanceFilter,
      );
    }
  }

  Future<void> _sendData(SendPort? sendPort, List<Trekko.Position> loc) async {
    Isar cache = (await Databases.cache.getInstance(openIfNone: true))!;
    List<Map<String, dynamic>> data = loc.map((e) => e.toJson()).toList();
    await cache.writeTxn(() async => await cache.cacheObjects
        .putAll(data.map(CacheObject.fromJson).toList()));
    data.forEach((element) => sendPort?.send(element));
  }

  @override
  void onDestroy(DateTime timestamp, SendPort? sendPort) {
    positionStream.cancel();
  }

  @override
  void onRepeatEvent(DateTime timestamp, SendPort? sendPort) async {}

  @override
  void onStart(DateTime timestamp, SendPort? sendPort) async {
    Isar cache = (await Databases.cache.getInstance(openIfNone: true))!;
    TrackingOptions? options = await cache.trackingOptions.where().findFirst();
    if (options == null) throw Exception("No tracking interval set");
    positionStream = Geolocator.getPositionStream(
            locationSettings: getLocationSettings(options))
        .listen((Position? position) {
      if (position != null) {
        _sendData(sendPort, [Trekko.Position.fromGeoPosition(position)]);
      }
    });
  }
}

@pragma('vm:entry-point')
void startCallback() {
  FlutterForegroundTask.setTaskHandler(TrackingTask());
}

class TrackingService {
  static String debugIsolateName = "tracking_service";
  static bool debug = false;
  static List<Function(Trekko.Position)> callbacks = [];

  static void init() {
    if (debug) return;

    FlutterForegroundTask.init(
      androidNotificationOptions: AndroidNotificationOptions(
        channelId: 'trekko_tracking_service',
        channelName: 'Trekko Tracking Service',
        channelDescription: 'Trekko Tracking Service',
        channelImportance: NotificationChannelImportance.MIN,
        priority: NotificationPriority.MIN,
        isSticky: true,
        visibility: NotificationVisibility.VISIBILITY_SECRET,
        iconData: const NotificationIconData(
          resType: ResourceType.mipmap,
          resPrefix: ResourcePrefix.ic,
          name: 'launcher',
        ),
      ),
      iosNotificationOptions: const IOSNotificationOptions(
        showNotification: true,
        playSound: false,
      ),
      foregroundTaskOptions: ForegroundTaskOptions(
        isOnceEvent: true,
        autoRunOnBoot: true,
        allowWakeLock: true,
      ),
    );
  }

  static Future<int> startLocationService(BatteryUsageSetting options) async {
    ReceivePort receivePort = ReceivePort();
    await Databases.cache.getInstance(openIfNone: true).then((value) => value!
        .writeTxn(() => value.trackingOptions.put(TrackingOptions(options))));

    if (!debug) {
      FlutterForegroundTask.startService(
          notificationTitle: "Trekko",
          notificationText: "Trekko verfolgt dich... Gib Acht!",
          callback: startCallback);
      receivePort = FlutterForegroundTask.receivePort!;
    } else {
      receivePort = ReceivePort();
      IsolateNameServer.registerPortWithName(
          receivePort.sendPort, debugIsolateName);
    }

    receivePort.listen((dynamic data) {
      callbacks.forEach((c) => c.call(Trekko.Position.fromJson(data)));
    });
    return 0;
  }

  static void stopLocationService(int id) {
    if (!debug) {
      FlutterForegroundTask.stopService();
    }
    callbacks.clear();
  }

  static void getLocationUpdates(Function(Trekko.Position) locationCallback) {
    callbacks.add(locationCallback);
  }
}
