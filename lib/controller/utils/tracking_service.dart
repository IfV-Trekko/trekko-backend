import 'dart:convert';
import 'dart:isolate';
import 'dart:ui';

import 'package:background_locator_2/background_locator.dart';
import 'package:background_locator_2/location_dto.dart';
import 'package:background_locator_2/settings/android_settings.dart';
import 'package:background_locator_2/settings/ios_settings.dart';
import 'package:background_locator_2/settings/locator_settings.dart';
import 'package:flutter/material.dart';
import 'package:trekko_backend/controller/utils/database_utils.dart';
import 'package:trekko_backend/model/cache_object.dart';
import 'package:trekko_backend/model/position.dart';

class TrackingService {
  static const String isolateName = "LocatorIsolate";
  static bool debug = false;
  static List<Function(Position)> callbacks = [];

  static Future<void> startLocationService(
      int interval, Databases cache) async {
    IsolateNameServer.removePortNameMapping(isolateName);
    ReceivePort port = ReceivePort();
    IsolateNameServer.registerPortWithName(port.sendPort, isolateName);
    port.listen((dynamic data) {
      callbacks.forEach((c) => c.call(Position.fromJson(data)));
    });

    if (!debug) {
      await BackgroundLocator.initialize();
      BackgroundLocator.registerLocationUpdate(locationCallback,
          autoStop: false,
          iosSettings: IOSSettings(
              accuracy: LocationAccuracy.NAVIGATION, distanceFilter: 0),
          androidSettings: AndroidSettings(
              accuracy: LocationAccuracy.NAVIGATION,
              interval: interval,
              distanceFilter: 0,
              wakeLockTime: 1440,
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

  static void locationCallback(LocationDto loc) {
    Map<String, dynamic> data = Position.fromLocationDto(loc).toJson();
    Databases.cache.getInstance(openIfNone: true).then((cache) {
      cache?.writeTxn(() => cache.cacheObjects
          .put(CacheObject(jsonEncode(data), loc.time.toInt())));
    });
    final SendPort? send = IsolateNameServer.lookupPortByName(isolateName);
    send?.send(data);
  }

  static void stopLocationService() {
    if (!debug) BackgroundLocator.unRegisterLocationUpdate();
    IsolateNameServer.removePortNameMapping(isolateName);
    callbacks.clear();
  }

  static void getLocationUpdates(Function(Position) locationCallback) {
    callbacks.add(locationCallback);
  }
}
