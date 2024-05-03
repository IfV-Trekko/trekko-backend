import 'dart:async';
import 'dart:convert';

import 'package:isar/isar.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:trekko_backend/controller/tracking/tracking.dart';
import 'package:trekko_backend/controller/utils/database_utils.dart';
import 'package:trekko_backend/controller/utils/logging.dart';
import 'package:trekko_backend/controller/utils/queued_executor.dart';
import 'package:trekko_backend/controller/utils/tracking_service.dart';
import 'package:trekko_backend/model/cache_object.dart';
import 'package:trekko_backend/model/position.dart';
import 'package:trekko_backend/model/profile/battery_usage_setting.dart';

class CachedTracking implements Tracking {
  late final Isar _cache;
  final QueuedExecutor _dataProcessor = QueuedExecutor();
  int _trackingId = 0;
  bool _trackingRunning = false;

  Future<List<Position>> _readCache() {
    return _cache.cacheObjects.where().sortByTimestamp().findAll().then(
        (value) =>
            value.map((e) => Position.fromJson(jsonDecode(e.value))).toList());
  }

  _process(Position position, Future Function(Position) callback) {
    _dataProcessor.add(() async {
      await callback(position);
    });
  }

  @override
  Future<void> init(BatteryUsageSetting options) async {
    _cache = (await Databases.cache.getInstance());
    TrackingService.init(options);
  }

  @override
  Future<bool> isRunning() {
    return Future.value(_trackingRunning);
  }

  @override
  Future<bool> start(
      BatteryUsageSetting setting, Future Function(Position) callback) async {
    if (_trackingRunning) return false;
    for (Permission perm in Tracking.perms) {
      PermissionStatus status = await perm.status;
      if (status != PermissionStatus.granted) {
        status = await perm.request();
        if (status != PermissionStatus.granted) {
          return false;
        }
      }
    }

    List<Position> initialPositions = await _readCache();
    if (initialPositions.isNotEmpty) {
      await Logging.info(
          "Processing ${initialPositions.length} initial positions");
      for (Position pos in initialPositions) {
        _process(pos, callback);
      }
    }

    TrackingService.getLocationUpdates((pos) async => _process(pos, callback));
    _trackingId = await TrackingService.startLocationService(setting);
    _trackingRunning = true;
    return true;
  }

  @override
  Future<bool> stop() async {
    if (!_trackingRunning) return false;
    await TrackingService.stopLocationService(_trackingId);
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
