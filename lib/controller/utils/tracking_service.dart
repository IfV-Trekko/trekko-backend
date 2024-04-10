import 'dart:async';
import 'dart:isolate';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:geolocator/geolocator.dart';
import 'package:isar/isar.dart';
import 'package:trekko_backend/controller/utils/database_utils.dart';
import 'package:trekko_backend/model/cache_object.dart';
import 'package:trekko_backend/model/position.dart' as Trekko;
import 'package:trekko_backend/model/profile/battery_usage_setting.dart';
import 'package:trekko_backend/model/tracking_options.dart';

class TrackingTask extends TaskHandler {
  final BatteryUsageSetting options;

  TrackingTask(this.options);

  Future<void> _sendData(SendPort? sendPort, List<Trekko.Position> loc) async {
    for (Trekko.Position pos in loc) {
      print(pos.timestamp);
    }
    Isar cache = (await Databases.cache.getInstance());
    List<Map<String, dynamic>> data = loc.map((e) => e.toJson()).toList();
    await cache.writeTxn(() async => await cache.cacheObjects
        .putAll(data.map(CacheObject.fromJson).toList()));
    data.forEach((element) => sendPort?.send(element));
  }

  @override
  void onDestroy(DateTime timestamp, SendPort? sendPort) {}

  @override
  void onRepeatEvent(DateTime timestamp, SendPort? sendPort) async {
    Geolocator.getCurrentPosition(desiredAccuracy: options.accuracy)
        .then((value) {
      _sendData(sendPort, [Trekko.Position.fromGeoPosition(value)]);
    });
  }

  @override
  void onStart(DateTime timestamp, SendPort? sendPort) async {}
}

@pragma('vm:entry-point')
void startCallback() async {
  WidgetsFlutterBinding.ensureInitialized();
  Isar cache = (await Databases.cache.getInstance());
  TrackingOptions? options = await cache.trackingOptions.where().findFirst();
  FlutterForegroundTask.setTaskHandler(TrackingTask(options!.batterySettings));
}

class TrackingService {
  static String debugIsolateName = "tracking_service";
  static bool debug = false;
  static List<Function(Trekko.Position)> callbacks = [];

  static void init(BatteryUsageSetting options) {
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
        allowWifiLock: true,
        interval: options.getInterval().inMilliseconds,
        isOnceEvent: false,
        autoRunOnBoot: true,
        allowWakeLock: true,
      ),
    );
  }

  static Future<int> startLocationService(BatteryUsageSetting options) async {
    ReceivePort receivePort = ReceivePort();
    await Databases.cache.getInstance().then((value) => value
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
