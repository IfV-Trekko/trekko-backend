import 'dart:async';
import 'dart:isolate';
import 'dart:ui';

import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:geolocator/geolocator.dart';
import 'package:isar/isar.dart';
import 'package:trekko_backend/controller/utils/database_utils.dart';
import 'package:trekko_backend/model/cache_object.dart';
import 'package:trekko_backend/model/position.dart' as Trekko;

class TrackingTask extends TaskHandler {
  Future<void> _sendData(SendPort? sendPort, List<Trekko.Position> loc) async {
    Isar cache = (await Databases.cache.getInstance(openIfNone: true))!;
    List<Map<String, dynamic>> data = loc.map((e) => e.toJson()).toList();
    await cache.writeTxn(() async => await cache.cacheObjects
        .putAll(data.map(CacheObject.fromJson).toList()));
    data.forEach((element) => sendPort?.send(element));
  }

  @override
  void onDestroy(DateTime timestamp, SendPort? sendPort) {}

  @override
  void onRepeatEvent(DateTime timestamp, SendPort? sendPort) async {
    Position pos = await Geolocator.getCurrentPosition();
    _sendData(sendPort, [Trekko.Position.fromGeoPosition(pos)]);
  }

  @override
  void onStart(DateTime timestamp, SendPort? sendPort) {}
}

@pragma('vm:entry-point')
void startCallback() {
  FlutterForegroundTask.setTaskHandler(TrackingTask());
}

class TrackingService {
  static String debugIsolateName = "tracking_service";
  static bool debug = false;
  static List<Function(Trekko.Position)> callbacks = [];

  static void init(Duration interval) {
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
        interval: interval.inMilliseconds,
        isOnceEvent: false,
        autoRunOnBoot: true,
        allowWakeLock:
            false, // TODO: This may drain the battery, check if necessary
      ),
    );
  }

  static Future<int> startLocationService() async {
    ReceivePort receivePort = ReceivePort();

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
