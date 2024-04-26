import 'dart:async';
import 'dart:isolate';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:geolocator/geolocator.dart';
import 'package:isar/isar.dart';
import 'package:trekko_backend/controller/utils/database_utils.dart';
import 'package:trekko_backend/controller/utils/logging.dart';
import 'package:trekko_backend/model/cache_object.dart';
import 'package:trekko_backend/model/position.dart' as Trekko;
import 'package:trekko_backend/model/profile/battery_usage_setting.dart';
import 'package:trekko_backend/model/tracking_options.dart';

class TrackingTask extends TaskHandler {
  final BatteryUsageSetting options;
  DateTime lastTimestamp = DateTime.now();

  TrackingTask(this.options);

  Future<void> _sendData(SendPort? sendPort, List<Trekko.Position> locs) async {
    List<Trekko.Position> valids = [];
    for (Trekko.Position p in locs) {
      if (p.timestamp.isAfter(lastTimestamp) &&
          !p.timestamp.isAtSameMomentAs(lastTimestamp)) {
        lastTimestamp = p.timestamp;
        valids.add(p);
      } else {
        await Logging.warning("Skipping position: ${p.toJson()}");
      }
    }

    await Logging.info("Sending ${valids.length} positions to cache");
    Isar cache = (await Databases.cache.getInstance());
    List<Map<String, dynamic>> data = valids.map((e) => e.toJson()).toList();
    await cache.writeTxn(() async => await cache.cacheObjects
        .putAll(data.map(CacheObject.fromJson).toList()));
    data.forEach((element) => sendPort?.send(element));
  }

  @override
  void onDestroy(DateTime timestamp, SendPort? sendPort) {
    Logging.warning("Tracking service destroyed");
  }

  @override
  void onRepeatEvent(DateTime timestamp, SendPort? sendPort) async {
    Geolocator.getCurrentPosition(desiredAccuracy: options.accuracy)
        .then((value) {
      _sendData(sendPort, [Trekko.Position.fromGeoPosition(value)]);
    });
  }

  @override
  void onStart(DateTime timestamp, SendPort? sendPort) async {
    Logging.warning("Tracking service started");
  }
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
  static List<Future Function(Trekko.Position)> callbacks = [];

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
          notificationText: "Trekko verfolgt dich... Gib acht!",
          callback: startCallback);
      receivePort = FlutterForegroundTask.receivePort!;
    } else {
      receivePort = ReceivePort();
      IsolateNameServer.registerPortWithName(
          receivePort.sendPort, debugIsolateName);
    }

    receivePort.listen((dynamic data) async {
      for (Future Function(Trekko.Position) callback in callbacks) {
        await callback.call(Trekko.Position.fromJson(data));
      }
    });
    return 0;
  }

  static void stopLocationService(int id) {
    if (!debug) {
      FlutterForegroundTask.stopService();
    }
    callbacks.clear();
  }

  static void getLocationUpdates(Future Function(Trekko.Position) locationCallback) {
    callbacks.add(locationCallback);
  }
}
