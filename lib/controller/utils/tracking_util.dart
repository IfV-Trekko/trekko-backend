import 'dart:async';
import 'dart:convert';
import 'dart:isolate';
import 'dart:ui';

import 'package:app_backend/controller/utils/database_utils.dart';
import 'package:app_backend/model/cache_object.dart';
import 'package:background_locator_2/background_locator.dart';
import 'package:background_locator_2/location_dto.dart';
import 'package:background_locator_2/settings/android_settings.dart';
import 'package:background_locator_2/settings/ios_settings.dart';
import 'package:background_locator_2/settings/locator_settings.dart';
import 'package:flutter/material.dart';
import 'package:isar/isar.dart';

class LocationCallbackHandler {
  static const String _isolateName = "LocatorIsolate";
  static const String _dbName = "locaiton";

  static bool isRunning() {
    return IsolateNameServer.lookupPortByName(_isolateName) != null;
  }

  static Future<void> initState() async {
    if (isRunning()) {
      shutdown();
    }

    Isar isar =
        Isar.getInstance(_dbName) ?? await DatabaseUtils.openCache(_dbName);
    ReceivePort port = ReceivePort();
    IsolateNameServer.registerPortWithName(port.sendPort, _isolateName);
    port.listen((dynamic dto) async {
      if (dto != null) {
        print("PUT");
        isar.writeTxn(() {
          String encode = jsonEncode(dto);
          LocationDto decode = LocationDto.fromJson(dto);
          return isar.cacheObjects
              .put(CacheObject(encode, decode.time.round()));
        });
      }
    });
    initPlatformState();
    startLocationService();
  }

  static Stream<List<LocationDto>> hook() {
    if (!isRunning()) throw Exception("Service not running");
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
    if (!isRunning()) throw Exception("Service not running");
    Isar isar = Isar.getInstance(_dbName)!;
    return isar.writeTxn(() => isar.cacheObjects.where().deleteAll());
  }

  static Future<void> initPlatformState() async {
    await BackgroundLocator.initialize();
  }

  static Future<void> shutdown() async {
    IsolateNameServer.removePortNameMapping(_isolateName);
    await BackgroundLocator.unRegisterLocationUpdate();
  }

  @pragma('vm:entry-point')
  static void callback(LocationDto locationDto) async {
    final SendPort? send = IsolateNameServer.lookupPortByName(_isolateName);
    send?.send(locationDto.toJson());
  }

//Optional
  @pragma('vm:entry-point')
  static void initCallback(dynamic _) {
    print('Plugin initialization');
  }

//Optional
  @pragma('vm:entry-point')
  static void notificationCallback() {
    print('User clicked on the notification');
  }

  @pragma("vm:entry-point")
  static void disposeCallback() {
    // TODO: save all uncollected data
    print('Dispose callback');
  }

  static void startLocationService() {
    BackgroundLocator.registerLocationUpdate(LocationCallbackHandler.callback,
        initCallback: LocationCallbackHandler.initCallback,
        // initDataCallback: data, // TODO: was das
        disposeCallback: LocationCallbackHandler.disposeCallback,
        autoStop: false,
        iosSettings: IOSSettings(
            accuracy: LocationAccuracy.NAVIGATION, distanceFilter: 0),
        androidSettings: AndroidSettings(
            accuracy: LocationAccuracy.NAVIGATION, // TODO: Depending on battery
            interval: 5,
            distanceFilter: 0,
            androidNotificationSettings: AndroidNotificationSettings(
                notificationChannelName: 'Location tracking',
                notificationTitle: 'Start Location Tracking',
                notificationMsg: 'Track location in background',
                notificationBigMsg:
                    'Background location is on to keep the app up-tp-date with your location. This is required for main features to work properly when the app is not running.',
                notificationIcon: '',
                notificationIconColor: Colors.grey,
                notificationTapCallback:
                    LocationCallbackHandler.notificationCallback)));
  }
}
