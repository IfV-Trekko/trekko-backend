import 'dart:isolate';
import 'dart:ui';

import 'package:background_locator_2/background_locator.dart';
import 'package:background_locator_2/location_dto.dart';
import 'package:background_locator_2/settings/android_settings.dart';
import 'package:background_locator_2/settings/ios_settings.dart';
import 'package:background_locator_2/settings/locator_settings.dart';
import 'package:flutter/material.dart';

class LocationCallbackHandler {
  static const String _isolateName = "LocatorIsolate";
  ReceivePort port = ReceivePort();

  Stream<LocationDto> initState() {
    IsolateNameServer.registerPortWithName(port.sendPort, _isolateName);
    initPlatformState();
    return port as Stream<LocationDto>;
  }

  Future<void> initPlatformState() async {
    await BackgroundLocator.initialize();
  }

  static Future<void> shutdown() async {
    IsolateNameServer.removePortNameMapping(_isolateName);
    await BackgroundLocator.unRegisterLocationUpdate();
  }

  @pragma('vm:entry-point')
  static void callback(LocationDto locationDto) async {
    final SendPort? send = IsolateNameServer.lookupPortByName(_isolateName);
    send?.send(locationDto);
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
    // TODO: implement disposeCallback
    print('Dispose callback');
  }

  static void startLocationService() {
    BackgroundLocator.registerLocationUpdate(LocationCallbackHandler.callback,
        initCallback: LocationCallbackHandler.initCallback,
        // initDataCallback: data, // TODO: was das
        disposeCallback: LocationCallbackHandler.disposeCallback,
        autoStop: false,
        iosSettings:
        IOSSettings(accuracy: LocationAccuracy.NAVIGATION, distanceFilter: 0),
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


