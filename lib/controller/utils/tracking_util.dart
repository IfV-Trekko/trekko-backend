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

  static bool isRunning() {
    return IsolateNameServer.lookupPortByName(_isolateName) != null;
  }

  static Future<void> initState() async {
    Isar isar = await DatabaseUtils.openCache("write_location");
    ReceivePort port = ReceivePort();
    IsolateNameServer.registerPortWithName(port.sendPort, _isolateName);
    print("REGISTER HOOK");
    port.listen((dynamic dto) {
      if (dto != null) {
        print("PUT");
        isar.writeTxn(() {
          return isar.cacheObjects.put(CacheObject(jsonEncode(dto)));
        });
      }
    });
    initPlatformState();
  }

  static Future<Stream<LocationDto>> hook() async {
    Isar isar = await DatabaseUtils.openCache("read_location");
    StreamController<LocationDto> controller = StreamController<LocationDto>();
    // Create timer to send locations to the stream
    Timer.periodic(Duration(seconds: 5), (timer) {
      if (controller.isClosed) {
        isar.close();
        timer.cancel();
        return;
      }

      print("TIMER");
      List<CacheObject> locations = isar.cacheObjects.where().findAllSync();
      isar.writeTxn(() async {
        for (CacheObject location in locations) {
          controller.add(LocationDto.fromJson(jsonDecode(location.value)));
          isar.cacheObjects.delete(location.id);
        }
      });
    });
    return controller.stream;
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
            accuracy: LocationAccuracy.NAVIGATION,
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
