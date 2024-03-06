import 'dart:async';
import 'dart:collection';
import 'dart:convert';
import 'dart:isolate';
import 'dart:ui';

import 'package:app_backend/controller/utils/database_utils.dart';
import 'package:app_backend/model/cache_object.dart';
import 'package:app_backend/model/profile/battery_usage_setting.dart';
import 'package:background_locator_2/background_locator.dart';
import 'package:background_locator_2/location_dto.dart';
import 'package:background_locator_2/settings/android_settings.dart';
import 'package:background_locator_2/settings/ios_settings.dart';
import 'package:background_locator_2/settings/locator_settings.dart';
import 'package:flutter/material.dart';
import 'package:isar/isar.dart';

class LocationBackgroundTracking {
  static const String _dbName = "location";
  static const String isolateName = "LocatorIsolate";
  static bool debug = false;
  static Isar? _isar;
  static final Queue<LocationDto> locationQueue = Queue<LocationDto>();
  static bool isProcessing = false;


  static Future<bool> isRunning() async {
    return debug || await BackgroundLocator.isServiceRunning();
  }

  static Future<Isar> _getDatabase() async {
    if (_isar == null) {
      if (Isar.getInstance(_dbName) != null) {
        _isar = Isar.getInstance(_dbName)!;
      } else {
        _isar = await DatabaseUtils.openCache(_dbName);
      }
    }
    return _isar!;
  }

  static Future<void> init(BatteryUsageSetting setting) async {
    if (await isRunning()) {
      throw "Cannot init twice";
    }
    await BackgroundLocator.initialize();
    startLocationService(setting);
  }

  static Future<List<LocationDto>> readCache() async {
    Isar isar = await _getDatabase();
    return isar.cacheObjects.where().sortByTimestamp().findAll().then((value) =>
        value.map((e) => LocationDto.fromJson(jsonDecode(e.value))).toList());
  }

  static void hook(Function(LocationDto) consumer) async {
    ReceivePort port = ReceivePort();

    if (IsolateNameServer.lookupPortByName(isolateName) != null) {
      IsolateNameServer.removePortNameMapping(isolateName);
    }
    IsolateNameServer.registerPortWithName(port.sendPort, isolateName);

    port.listen((message) async {
      LocationDto loc = LocationDto.fromJson(jsonDecode(message));
      locationQueue.add(loc);
      if (!isProcessing) {
        processNextLocation(consumer);
      }
    });
  }

  static void processNextLocation(Function(LocationDto) consumer) async {
    if (locationQueue.isEmpty) {
      isProcessing = false;
      return;
    }

    isProcessing = true;
    LocationDto loc = locationQueue.removeFirst();
    await consumer(loc);

    processNextLocation(consumer);
  }

  static Future<void> clearCache() async {
    Isar isar = await _getDatabase();
    return isar.writeTxn(() => isar.cacheObjects.where().deleteAll());
  }

  static Future<void> initPlatformState() async {
    await BackgroundLocator.initialize();
  }

  static Future<void> shutdown() async {
    if (debug) return;
    await (await _getDatabase()).close();
    await BackgroundLocator.unRegisterLocationUpdate();
  }

  @pragma('vm:entry-point')
  static Future<void> callback(LocationDto locationDto) async {
    return _getDatabase().then((isar) async {
      await isar.writeTxn(() {
        String encode = jsonEncode(locationDto.toJson());
        SendPort? port = IsolateNameServer.lookupPortByName(isolateName);
        if (port != null) port.send(encode);
        return isar.cacheObjects
            .put(CacheObject(encode, locationDto.time.round()));
      });
    });
  }

//Optional
  @pragma('vm:entry-point')
  static void initCallback(dynamic _) {
    print('Plugin initialization');
  }

  static void startLocationService(BatteryUsageSetting setting) {
    BackgroundLocator.registerLocationUpdate(
        LocationBackgroundTracking.callback,
        initCallback: LocationBackgroundTracking.initCallback,
        autoStop: false,
        iosSettings: IOSSettings(
            accuracy: LocationAccuracy.NAVIGATION, distanceFilter: 0),
        androidSettings: AndroidSettings(
            accuracy: LocationAccuracy.NAVIGATION,
            interval: setting.interval,
            distanceFilter: 0,
            androidNotificationSettings: AndroidNotificationSettings(
                notificationChannelName: 'Tracking',
                notificationTitle: 'Trekko',
                notificationMsg: 'Sammeln von Standortdaten...',
                notificationBigMsg:
                    'Um die Wegeerkennung zu nutzen, sammeln wir Standortdaten. Diese werden nur lokal gespeichert und auch nur nach Wahl gespendet.',
                notificationIcon: '',
                notificationIconColor: Colors.grey)));
  }
}
