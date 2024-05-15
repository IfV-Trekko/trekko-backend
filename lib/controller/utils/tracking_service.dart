import 'dart:async';
import 'dart:isolate';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:isar/isar.dart';
import 'package:trekko_backend/controller/utils/database_utils.dart';
import 'package:trekko_backend/controller/utils/logging.dart';
import 'package:trekko_backend/controller/utils/position_utils.dart';
import 'package:trekko_backend/model/cache/cache_object.dart';
import 'package:trekko_backend/model/position.dart' as Trekko;
import 'package:trekko_backend/model/profile/battery_usage_setting.dart';
import 'package:trekko_backend/model/cache/tracking_options.dart';

class TrackingTask extends TaskHandler {
  final BatteryUsageSetting options;
  DateTime? lastTimestamp;

  TrackingTask(this.options);

  Future<void> _sendData(SendPort? sendPort, List<Trekko.Position> locs) async {
    List<Trekko.Position> valids = [];
    for (Trekko.Position p in locs) {
      if (lastTimestamp == null ||
          (p.timestamp.isAfter(lastTimestamp!) &&
              !p.timestamp.isAtSameMomentAs(lastTimestamp!))) {
        lastTimestamp = p.timestamp;
        valids.add(p);
      } else {
        await Logging.warning("Skipping position: ${p.toJson()}");
      }
    }

    if (valids.isEmpty) return;
    Isar cache = (await Databases.cache.getInstance());
    if (!await FlutterForegroundTask.isAppOnForeground) {
      await Logging.info("Sending ${valids.length} positions to cache");
      List<Map<String, dynamic>> data = valids.map((e) => e.toJson()).toList();
      await cache.writeTxn(() async => await cache.cacheObjects
          .putAll(data.map(CacheObject.fromJson).toList()));
    } else {
      if (cache.cacheObjects.where().isNotEmptySync()) {
        await Logging.info("Sending cached positions first");
        List<CacheObject> cached =
            await cache.cacheObjects.where().sortByTimestamp().findAll();
        cached.forEach((element) => sendPort!.send(element.value));
        await cache.writeTxn(() => cache.cacheObjects.where().deleteAll());
      }

      await Logging.info("Sending ${valids.length} positions directly");
      valids.forEach((element) => sendPort!.send(element.toJson()));
    }
  }

  @override
  void onDestroy(DateTime timestamp, SendPort? sendPort) {
    Logging.warning("Tracking service destroyed");
  }

  @override
  void onRepeatEvent(DateTime timestamp, SendPort? sendPort) async {
    PositionUtils.getPosition(options.accuracy)
        .then((value) => _sendData(sendPort, [value!]));
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
  static ReceivePort? receivePort;

  static void init(BatteryUsageSetting options) {
    if (debug) return;

    FlutterForegroundTask.init(
      androidNotificationOptions: AndroidNotificationOptions(
        channelId: 'trekko_tracking_service',
        channelName: 'Trekko Tracking Service',
        channelDescription: 'Trekko Tracking Service',
        channelImportance: NotificationChannelImportance.NONE,
        priority: NotificationPriority.MIN,
        isSticky: true,
        visibility: NotificationVisibility.VISIBILITY_SECRET,
        foregroundServiceType: AndroidForegroundServiceType.LOCATION,
        showWhen: false,
        playSound: false,
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
    await Databases.cache.getInstance().then((value) => value
        .writeTxn(() => value.trackingOptions.put(TrackingOptions(options))));

    if (!debug) {
      if (!await FlutterForegroundTask.isRunningService) {
        bool service = await FlutterForegroundTask.startService(
            notificationTitle: "Trekko",
            notificationText: "Trekko verfolgt dich... Gib acht!",
            callback: startCallback);
        if (!service) throw Exception("Failed to start service");
      }
      receivePort = FlutterForegroundTask.receivePort!;
    } else {
      receivePort = ReceivePort();
      bool register = IsolateNameServer.registerPortWithName(
          receivePort!.sendPort, debugIsolateName);
      if (!register) throw Exception("Failed to register port");
    }

    receivePort!.listen((dynamic data) async {
      for (Future Function(Trekko.Position) callback in callbacks) {
        await callback.call(Trekko.Position.fromJson(data));
      }
    });
    return 0;
  }

  static Future stopLocationService(int id) async {
    if (!debug) {
      await FlutterForegroundTask.stopService();
    } else {
      IsolateNameServer.removePortNameMapping(debugIsolateName);
      receivePort?.close();
      receivePort = null;
    }

    callbacks.clear();
  }

  static void getLocationUpdates(
      Future Function(Trekko.Position) locationCallback) {
    callbacks.add(locationCallback);
  }
}
