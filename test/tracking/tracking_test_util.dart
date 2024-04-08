import 'dart:convert';
import 'dart:isolate';
import 'dart:ui';

import 'package:isar/isar.dart';
import 'package:trekko_backend/controller/trekko.dart';
import 'package:trekko_backend/controller/utils/database_utils.dart';
import 'package:trekko_backend/controller/utils/tracking_service.dart';
import 'package:trekko_backend/model/cache_object.dart';
import 'package:trekko_backend/model/position.dart';

class TrackingTestUtil {
  static Future<void> init() async {
    TrackingService.debug = true;
    print("Initialized tracking test util");
  }

  static Future<void> clearCache() async {
    Isar cache = (await Databases.cache.getInstance(openIfNone: true))!;
    await cache.writeTxn(() async {
      await cache.cacheObjects.where().deleteAll();
    });
  }

  static Future<void> sendToCache(List<Position> positions) async {
    print("Sending " + positions.length.toString() + " positions to cache");
    Isar cache = (await Databases.cache.getInstance(openIfNone: true))!;
    await cache.writeTxn(() async {
      for (Position pos in positions) {
        await cache.cacheObjects.put(CacheObject(
            jsonEncode(pos.toJson()), pos.timestamp.millisecondsSinceEpoch));
      }
    });
  }

  static Future<void> sendPositions(
      Trekko trekko, List<Position> positions) async {
    print("Sending " + positions.length.toString() + " positions");
    final SendPort? send =
        IsolateNameServer.lookupPortByName(TrackingService.debugIsolateName);
    if (send == null) throw Exception("No send port");
    for (Position pos in positions) {
      send.send(pos.toJson());
    }

    print("Finished sending positions; " +
        positions.length.toString() +
        " positions sent");
    await waitForFinishProcessing(trekko);
  }

  static Future<void> waitForFinishProcessing(Trekko trekko) async {
    while (trekko.isProcessingLocationData()) {
      await Future.delayed(Duration(milliseconds: 50));
    }
    await Future.delayed(Duration(milliseconds: 3000));
  }
}
