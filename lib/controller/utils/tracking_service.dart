import 'dart:async';
import 'dart:isolate';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:isar/isar.dart';
import 'package:flutter_activity_recognition/flutter_activity_recognition.dart';
import 'package:trekko_backend/controller/utils/database_utils.dart';
import 'package:trekko_backend/controller/utils/logging.dart';
import 'package:trekko_backend/controller/utils/position_utils.dart';
import 'package:trekko_backend/model/tracking/activity_data.dart';
import 'package:trekko_backend/model/tracking/cache/cache_object.dart';
import 'package:trekko_backend/model/tracking/cache/raw_phone_data_type.dart';
import 'package:trekko_backend/model/profile/battery_usage_setting.dart';
import 'package:trekko_backend/model/tracking/cache/tracking_options.dart';
import 'package:trekko_backend/model/tracking/raw_phone_data.dart';

class TrackingTask extends TaskHandler {
  final BatteryUsageSetting options;
  DateTime? lastTimestamp;
  List<StreamSubscription> _subscriptions = [];

  TrackingTask(this.options);

  Future<void> _sendData(SendPort? sendPort, List<RawPhoneData> data) async {
    List<RawPhoneData> valids = [];
    for (RawPhoneData p in data) {
      if (lastTimestamp == null ||
          (p.getTimestamp().isAfter(lastTimestamp!) &&
              !p.getTimestamp().isAtSameMomentAs(lastTimestamp!))) {
        lastTimestamp = p.getTimestamp();
        valids.add(p);
      } else {
        await Logging.warning("Skipping position: ${p.toJson()}");
      }
    }

    if (valids.isEmpty) return;
    if (!await FlutterForegroundTask.isAppOnForeground) {
      Isar cache = (await Databases.cache.getInstance());
      await Logging.info("Sending ${valids.length} positions to cache");
      List<Map<String, dynamic>> data = valids.map((e) => e.toJson()).toList();
      await cache.writeTxn(() async => await cache.cacheObjects
          .putAll(data.map(CacheObject.fromJson).toList()));
    } else {
      await Logging.info("Sending ${valids.length} positions directly");
      valids.forEach((element) => sendPort!.send(element.toJson()));
    }
  }

  @override
  void onDestroy(DateTime timestamp, SendPort? sendPort) {
    _subscriptions.forEach((s) => s.cancel());
    Logging.warning("Tracking service destroyed");
  }

  @override
  void onRepeatEvent(DateTime timestamp, SendPort? sendPort) async {
    PositionUtils.getPosition(options.accuracy)
        .then((value) => _sendData(sendPort, [value!]));
  }

  @override
  void onStart(DateTime timestamp, SendPort? sendPort) async {
    _subscriptions.add(FlutterActivityRecognition.instance.activityStream
        .listen((event) async {
      await _sendData(sendPort, [
        ActivityData(
            activity: event.type,
            confidence: event.confidence,
            timestamp: DateTime.now())
      ]);
    }));

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
  static List<Function(RawPhoneData)> callbacks = [];
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

    receivePort!.listen((dynamic data) {
      for (Function(RawPhoneData) callback in callbacks) {
        callback.call(RawPhoneDataType.parseData(data));
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

  static void getLocationUpdates(Function(RawPhoneData) locationCallback) {
    callbacks.add(locationCallback);
  }
}
