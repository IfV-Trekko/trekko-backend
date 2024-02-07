import 'dart:async';
import 'dart:convert';

import 'package:app_backend/controller/utils/database_utils.dart';
import 'package:app_backend/model/cache_object.dart';
import 'package:app_backend/model/profile/battery_usage_setting.dart';
import 'package:background_locator_2/background_locator.dart';
import 'package:background_locator_2/location_dto.dart';
import 'package:background_locator_2/settings/android_settings.dart';
import 'package:background_locator_2/settings/ios_settings.dart';
import 'package:flutter/material.dart';
import 'package:isar/isar.dart';

class LocationBackgroundTracking {
  static const String _dbName = "location";

  static Future<bool> isRunning() async {
    return await BackgroundLocator.isServiceRunning();
  }

  static Future<Isar> _getDatabase() async {
    return Isar.getInstance(_dbName) ?? await DatabaseUtils.openCache(_dbName);
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

  static Future<Stream<LocationDto>> hook() async {
    Isar isar = await _getDatabase();
    return isar.cacheObjects.watchLazy().map((void event) {
      CacheObject? last =
          isar.cacheObjects.where().sortByTimestampDesc().findFirstSync();
      return LocationDto.fromJson(jsonDecode(last!.value));
    });
  }

  static Future<void> clearCache() async {
    Isar isar = await _getDatabase();
    return isar.writeTxn(() => isar.cacheObjects.where().deleteAll());
  }

  static Future<void> initPlatformState() async {
    await BackgroundLocator.initialize();
  }

  static Future<void> shutdown() async {
    await (await _getDatabase()).close();
    await BackgroundLocator.unRegisterLocationUpdate();
  }

  @pragma('vm:entry-point')
  static void callback(LocationDto locationDto) async {
    Isar isar = await _getDatabase();
    await isar.writeTxn(() {
      String encode = jsonEncode(locationDto.toJson());
      return isar.cacheObjects
          .put(CacheObject(encode, locationDto.time.round()));
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
        iosSettings: IOSSettings(accuracy: setting.accuracy, distanceFilter: 0),
        androidSettings: AndroidSettings(
            accuracy: setting.accuracy,
            interval: 5,
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
