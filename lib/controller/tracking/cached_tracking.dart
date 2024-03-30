import 'dart:async';
import 'dart:convert';

import 'package:isar/isar.dart';
import 'package:trekko_backend/controller/tracking/tracking.dart';
import 'package:trekko_backend/controller/utils/database_utils.dart';
import 'package:trekko_backend/controller/utils/queued_executor.dart';
import 'package:trekko_backend/controller/utils/tracking_service.dart';
import 'package:trekko_backend/model/cache_object.dart';
import 'package:trekko_backend/model/position.dart';
import 'package:trekko_backend/model/profile/battery_usage_setting.dart';

class CachedTracking implements Tracking {
  late final Isar _cache;
  final QueuedExecutor _dataProcessor = QueuedExecutor();
  final StreamController<Position> _positionStream =
      StreamController<Position>.broadcast(sync: true);
  bool _trackingRunning = false;

  Future<List<Position>> _clearAndReadCache() {
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

  Future<void> _processLocation(Position position) async {
    if (!_cache.isOpen) throw Exception("Cache is not open");
    String locationJson = jsonEncode(position.toJson());
    await _cache.writeTxn(() => _cache.cacheObjects.put(
        CacheObject(locationJson, position.timestamp.millisecondsSinceEpoch)));
    _positionStream.add(position);
  }

  void _locationCallback(Position position) async {
    _dataProcessor.add(() => _processLocation(position));
  }

  @override
  Future<void> init() async {
    _cache = (await Databases.cache.getInstance(openIfNone: true))!;
    _positionStream.onListen = () async {
      List<Position> positions = await _clearAndReadCache();
      for (Position position in positions) {
        _positionStream.add(position);
      }
    };
  }

  @override
  Future<bool> isRunning() {
    return Future.value(_trackingRunning);
  }

  @override
  Stream<Position> track(BatteryUsageSetting setting) {
    if (!_trackingRunning) {
      TrackingService.startLocationService(setting.interval);
      TrackingService.getLocationUpdates(_locationCallback);
      _trackingRunning = true;
    }

    return _positionStream.stream;
  }

  @override
  Future<bool> stop() async {
    if (!_trackingRunning) return false;
    if (_dataProcessor.isProcessing) throw Exception("Data processing is still running");

    TrackingService.stopLocationService();
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
  bool isProcessing() {
    return _dataProcessor.isProcessing;
  }
}
