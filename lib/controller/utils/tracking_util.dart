import 'dart:async';
import 'dart:convert';

import 'package:app_backend/controller/utils/database_utils.dart';
import 'package:app_backend/model/cache_object.dart';
import 'package:background_locator_2/background_locator.dart';
import 'package:background_locator_2/location_dto.dart';
import 'package:background_locator_2/settings/android_settings.dart';
import 'package:background_locator_2/settings/ios_settings.dart';
import 'package:background_locator_2/settings/locator_settings.dart';
import 'package:flutter/material.dart';
import 'package:isar/isar.dart';

class LocationBackgroundTracking {
  static const String _dbName = "location";

  static Future<bool> isRunning() async {
    return await BackgroundLocator.isServiceRunning();
  }

  static Future<void> init() async {
    if (await isRunning()) {
      throw "Cannot init twice";
    }
    await BackgroundLocator.initialize();
    startLocationService();
  }

  static Stream<List<LocationDto>> hook() {
    Isar isar = Isar.getInstance(_dbName)!;
    return isar.cacheObjects
        .where()
        .sortByTimestamp()
        .watch(fireImmediately: true)
        .map((event) => event
            .map((e) => LocationDto.fromJson(jsonDecode(e.value)))
            .toList());
  }

  static Future<void> onEditFinish() async {
    Isar isar = Isar.getInstance(_dbName)!;
    return isar.writeTxn(() => isar.cacheObjects.where().deleteAll());
  }

  static Future<void> initPlatformState() async {
    await BackgroundLocator.initialize();
  }

  static Future<void> shutdown() async {
    await BackgroundLocator.unRegisterLocationUpdate();
  }

  @pragma('vm:entry-point')
  static void callback(LocationDto locationDto) async {
    Isar isar =
        Isar.getInstance(_dbName) ?? await DatabaseUtils.openCache(_dbName);
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

  static void startLocationService() {
    BackgroundLocator.registerLocationUpdate(LocationBackgroundTracking.callback,
        initCallback: LocationBackgroundTracking.initCallback,
        autoStop: false,
        iosSettings: IOSSettings(
            accuracy: LocationAccuracy.NAVIGATION, distanceFilter: 0),
        androidSettings: AndroidSettings(
            accuracy: LocationAccuracy.NAVIGATION,
            // TODO: Depending on battery
            interval: 5,
            distanceFilter: 0,
            androidNotificationSettings: AndroidNotificationSettings(
                notificationChannelName: 'Location tracking',
                notificationTitle: 'Start Location Tracking',
                notificationMsg: 'Track location in background',
                notificationBigMsg:
                    'Background location is on to keep the app up-tp-date with your location. This is required for main features to work properly when the app is not running.',
                notificationIcon: '',
                notificationIconColor: Colors.grey)));
  }
}
