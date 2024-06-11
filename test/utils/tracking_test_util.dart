import 'dart:convert';
import 'dart:ffi';
import 'dart:isolate';
import 'dart:ui';

import 'package:fling_units/fling_units.dart';
import 'package:isar/isar.dart';
import 'package:trekko_backend/controller/trekko.dart';
import 'package:trekko_backend/controller/utils/database_utils.dart';
import 'package:trekko_backend/controller/utils/tracking_service.dart';
import 'package:trekko_backend/model/tracking/analyzer/analyzer_cache.dart';
import 'package:trekko_backend/model/tracking/cache/cache_object.dart';
import 'package:trekko_backend/model/tracking/raw_phone_data.dart';
import 'package:trekko_backend/model/tracking_state.dart';
import 'package:trekko_backend/model/trip/trip.dart';

import '../trekko_test_utils.dart';
import 'data_builder.dart';

List<RawPhoneData> walkToShop =
    DataBuilder().stay(1.hours).walk(500.meters).stay(1.hours).collect();

List<RawPhoneData> walkToShopAndBack = DataBuilder()
    .stay(1.hours)
    .walk(500.meters)
    .stay(5.minutes)
    .walk(forward: false, 500.meters)
    .stay(1.hours)
    .collect();

class TrackingTestUtil {
  static Future<void> init() async {
    TrackingService.debug = true;
    await TrackingTestUtil.clearCache();
    print("Initialized tracking test util");
  }

  static Future<void> clearCache() async {
    Isar cache = (await Databases.cache.getInstance());
    await cache.writeTxn(() async {
      await cache.cacheObjects.where().deleteAll();
      await cache.analyzerCaches.where().deleteAll();
    });
  }

  static Future<void> sendToCache(List<RawPhoneData> data) async {
    print("Sending " + data.length.toString() + " data to cache");
    Isar cache = (await Databases.cache.getInstance());
    await cache.writeTxn(() async {
      for (RawPhoneData pos in data) {
        await cache.cacheObjects.put(CacheObject(jsonEncode(pos.toJson()),
            pos.getTimestamp().millisecondsSinceEpoch));
      }
    });
    print("Finished sending " + data.length.toString() + " data to cache");
  }

  static Future<void> sendData(Trekko trekko, List<RawPhoneData> data) async {
    final SendPort? send =
        IsolateNameServer.lookupPortByName(TrackingService.debugIsolateName);
    print("Sending " +
        data.length.toString() +
        " positions to ${send!.nativePort}");
    // if (send == null) throw Exception("No send port");
    for (RawPhoneData pos in data) {
      send.send(pos.toJson());
    }

    print("Finished sending " + data.length.toString() + " positions");
    await waitForFinishProcessing(trekko);
  }

  static Future<void> waitForFinishProcessing(Trekko trekko) async {
    print("Waiting for processing to finish...");
    do {
      await Future.delayed(Duration(milliseconds: 50));
    } while (trekko.isProcessingLocationData());
    await Future.delayed(Duration(milliseconds: 3000));
    print("Finished processing");
  }

  static Future<void> sendCacheAndData(List<RawPhoneData> data, double inCache,
      Function(List<Trip>) test) async {
    print("Cache and position ratio: " + inCache.toString());
    int itemsInCache = inCache != 0 ? data.length ~/ inCache : 0;
    await TrackingTestUtil.sendToCache(data.sublist(0, itemsInCache));
    Trekko trekko = await TrekkoTestUtils.initTrekko(signOut: false);
    await trekko.terminate();

    trekko = await TrekkoTestUtils.initTrekko(signOut: false);
    await trekko.setTrackingState(TrackingState.running);

    await TrackingTestUtil.sendData(trekko, data.sublist(itemsInCache));

    test.call(await trekko.getTripQuery().collect());
    await TrekkoTestUtils.close(trekko);
  }

  static Future<void> sendDataDiverse(
      List<RawPhoneData> data, Function(List<Trip>) test) async {
    await sendCacheAndData(data, 0, test);
    await sendCacheAndData(data, 2, test);
    await sendCacheAndData(data, 1, test);
  }
}
