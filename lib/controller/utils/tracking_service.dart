import 'dart:isolate';
import 'dart:ui';

import 'package:huawei_location/huawei_location.dart';
import 'package:isar/isar.dart';
import 'package:trekko_backend/controller/utils/database_utils.dart';
import 'package:trekko_backend/model/cache_object.dart';
import 'package:trekko_backend/model/position.dart';

class TrackingService {
  static const String isolateName = "LocatorIsolate";
  static bool debug = false;
  static List<Function(Position)> callbacks = [];

  static Future<int> startLocationService(
      int interval, Databases cache) async {
    IsolateNameServer.removePortNameMapping(isolateName);
    ReceivePort port = ReceivePort();
    IsolateNameServer.registerPortWithName(port.sendPort, isolateName);
    port.listen((dynamic data) {
      callbacks.forEach((c) => c.call(Position.fromJson(data)));
    });

    if (!debug) {
      FusedLocationProviderClient _service = FusedLocationProviderClient();
      await _service.initFusedLocationService();
      LocationRequest locationRequest = LocationRequest();
      locationRequest.interval = interval;
      locationRequest.priority = LocationRequest.PRIORITY_HIGH_ACCURACY;
      locationRequest.fastestInterval = interval;
      locationRequest.smallestDisplacement = 0;
      locationRequest.maxWaitTime = 1440;
      locationRequest.needAddress = false;
      locationRequest.language = "de";
      locationRequest.countryCode = "DE";
      int id = await _service.requestLocationUpdatesCb(
          locationRequest,
          LocationCallback(onLocationResult: (LocationResult locationResult) {
            locationCallback(locationResult.locations!
                .where((element) => element != null)
                .map((e) => Position.fromLocation(e!))
                .toList());
          }, onLocationAvailability:
              (LocationAvailability locationAvailability) {
            print("Location availability: " +
                locationAvailability.isLocationAvailable.toString());
          }));
      BackgroundNotification notification = BackgroundNotification(
        category: 'service',
        priority: 2,
        channelName: 'Trekko',
        contentTitle: 'Position',
        contentText: 'Position Notification',
      );
      await _service.enableBackgroundLocation(1, notification);
      return id;
    }
    return 0;
  }

  static void locationCallback(List<Position> loc) async {
    Isar cache = (await Databases.cache.getInstance(openIfNone: true))!;
    List<Map<String, dynamic>> data = loc.map((e) => e.toJson()).toList();
    await cache.writeTxn(() async => await
        cache.cacheObjects.putAll(data.map(CacheObject.fromJson).toList()));
    final SendPort? send = IsolateNameServer.lookupPortByName(isolateName);
    data.forEach((element) => send?.send(element));
  }

  static void stopLocationService(int id) {
    if (!debug) {
      FusedLocationProviderClient _service = FusedLocationProviderClient();
      _service.removeLocationUpdates(id);
      _service.disableBackgroundLocation();
    }
    IsolateNameServer.removePortNameMapping(isolateName);
    callbacks.clear();
  }

  static void getLocationUpdates(Function(Position) locationCallback) {
    callbacks.add(locationCallback);
  }
}
