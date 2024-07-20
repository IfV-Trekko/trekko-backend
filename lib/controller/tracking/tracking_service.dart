import 'dart:async';
import 'dart:convert';
import 'dart:isolate';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter_activity_recognition/flutter_activity_recognition.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:isar/isar.dart';
import 'package:trekko_backend/controller/utils/database_utils.dart';
import 'package:trekko_backend/controller/utils/logging.dart';
import 'package:trekko_backend/controller/utils/position_utils.dart';
import 'package:trekko_backend/controller/utils/queued_executor.dart';
import 'package:trekko_backend/model/profile/battery_usage_setting.dart';
import 'package:trekko_backend/model/tracking/activity_data.dart';
import 'package:trekko_backend/model/tracking/cache/cache_object.dart';
import 'package:trekko_backend/model/tracking/cache/raw_phone_data_type.dart';
import 'package:trekko_backend/model/tracking/cache/tracking_options.dart';
import 'package:trekko_backend/model/tracking/position.dart';
import 'package:trekko_backend/model/tracking/raw_phone_data.dart';

class TrackingTask extends TaskHandler {
  final BatteryUsageSetting options;
  DateTime? lastTimestamp;
  List<StreamSubscription> _subscriptions = [];
  QueuedExecutor executor = QueuedExecutor();

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
        await Logging.warning(
            "Skipping data point: ${p.toJson()} of type ${p.getType()}");
      }
    }

    if (valids.isEmpty) return;
    if (!await FlutterForegroundTask.isAppOnForeground) {
      Isar cache = (await Databases.cache.getInstance());
      await Logging.info("Sending ${valids.length} data points to cache");
      List<Map<String, dynamic>> data = valids.map((e) => e.toJson()).toList();
      await cache.writeTxn(() async => await cache.cacheObjects
          .putAll(data.map(CacheObject.fromJson).toList()));
    } else {
      await Logging.info("Sending ${valids.length} data points directly");
      String encode = jsonEncode(valids.map((e) => e.toJson()).toList());
      sendPort!.send(encode);
    }
  }

  @override
  void onDestroy(DateTime timestamp, SendPort? sendPort) {
    _subscriptions.forEach((s) => s.cancel());
    Logging.warning("Tracking service destroyed");
  }

  @override
  void onRepeatEvent(DateTime timestamp, SendPort? sendPort) {
    executor.add(() async => await _sendData(
        sendPort, [(await PositionUtils.getPosition(options.accuracy))!]));
  }

  @override
  void onStart(DateTime timestamp, SendPort? sendPort) {
    _subscriptions
        .add(FlutterActivityRecognition.instance.activityStream.listen((event) {
      executor.add(() async {
        DateTime now = DateTime.now();
        Position? pos = await PositionUtils.getPosition(options.accuracy);
        await _sendData(sendPort, [
          Position(
              latitude: pos!.latitude,
              longitude: pos.longitude,
              timestamp: now.add(Duration(seconds: -1)),
              accuracy: pos.accuracy),
          ActivityData(
              activity: event.type,
              confidence: event.confidence,
              timestamp: now),
          Position(
              latitude: pos.latitude,
              longitude: pos.longitude,
              timestamp: now.add(Duration(seconds: 1)),
              accuracy: pos.accuracy),
        ]);
      });
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
  static List<Function(Iterable<RawPhoneData>)> callbacks = [];
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
        visibility: NotificationVisibility.VISIBILITY_SECRET,
        showWhen: false,
        playSound: false,
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
        ServiceRequestResult service = await FlutterForegroundTask.startService(
            notificationTitle: "Trekko",
            notificationText: "Trekko verfolgt dich... Gib acht!",
            callback: startCallback);
        if (!service.success) throw Exception("Failed to start service");
      }
      receivePort = FlutterForegroundTask.receivePort!;
    } else {
      receivePort = ReceivePort();
      IsolateNameServer.removePortNameMapping(debugIsolateName);
      bool register = IsolateNameServer.registerPortWithName(
          receivePort!.sendPort, debugIsolateName);
      if (!register) throw Exception("Failed to register port");
    }

    receivePort!.listen((dynamic data) {
      List<dynamic> strings = jsonDecode(data);
      Iterable<RawPhoneData> parsed = strings.map(RawPhoneDataType.parseData);
      for (Function(Iterable<RawPhoneData>) callback in callbacks) {
        callback.call(parsed);
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
      Function(Iterable<RawPhoneData>) locationCallback) {
    callbacks.add(locationCallback);
  }
}
