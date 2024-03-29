import 'dart:async';
import 'dart:convert';

import 'package:isar/isar.dart';
import 'package:trekko_backend/controller/tracking/tracking.dart';
import 'package:trekko_backend/controller/utils/database_utils.dart';
import 'package:trekko_backend/controller/utils/tracking_service.dart';
import 'package:trekko_backend/model/cache_object.dart';
import 'package:trekko_backend/model/position.dart';
import 'package:trekko_backend/model/profile/battery_usage_setting.dart';

class CachedTracking implements Tracking {
  static const String _dbName = "location";
  static bool debug = false;

  late final Isar _cache;
  final StreamController<Position> _positionStream =
      StreamController<Position>();
  bool _trackingRunning = false;

  Future<void> locationCallback(Position position) async {
    _positionStream.add(position);

    String locationJson = jsonEncode(position.toJson());
    return await _cache.writeTxn(() {
      return _cache.cacheObjects.put(
          CacheObject(locationJson, position.timestamp.millisecondsSinceEpoch));
    });
  }

  @override
  Future<void> init() async {
    if (Isar.getInstance(_dbName) != null) {
      _cache = Isar.getInstance(_dbName)!;
    } else {
      _cache = await Databases.cache.open();
    }

    if (!debug) TrackingService.getLocationUpdates(locationCallback);
  }

  @override
  Future<bool> isRunning() {
    return Future.value(_trackingRunning);
  }

  @override
  Stream<Position> track(BatteryUsageSetting setting) {
    if (_trackingRunning) return _positionStream.stream;

    if (!debug) TrackingService.startLocationService(setting.interval);
    return _positionStream.stream;
  }

  @override
  Future<bool> stop() async {
    if (!_trackingRunning) return false;

    if (!debug) TrackingService.stopLocationService();
    await _positionStream.close();
    await _cache.close();
    _trackingRunning = false;
    return true;
  }

  @override
  Future<void> clearCache() async {
    await _cache.writeTxn(() => _cache.cacheObjects.where().deleteAll());
  }

  @override
  Future<List<Position>> clearAndReadCache() {
    Future<List<Position>> result = _cache.cacheObjects
        .where()
        .sortByTimestamp()
        .findAll()
        .then((value) =>
            value.map((e) => Position.fromJson(jsonDecode(e.value))).toList());
    return result.then((value) async {
      await clearCache();
      return value;
    });
  }
}
