import 'dart:async';
import 'dart:convert';

import 'package:isar/isar.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:trekko_backend/controller/tracking/tracking.dart';
import 'package:trekko_backend/controller/utils/database_utils.dart';
import 'package:trekko_backend/controller/utils/logging.dart';
import 'package:trekko_backend/controller/utils/queued_executor.dart';
import 'package:trekko_backend/controller/utils/tracking_service.dart';
import 'package:trekko_backend/model/cache/cache_object.dart';
import 'package:trekko_backend/model/position.dart';
import 'package:trekko_backend/model/profile/battery_usage_setting.dart';

class CachedTracking implements Tracking {
  final QueuedExecutor _dataProcessor = QueuedExecutor();
  int _trackingId = 0;
  bool _trackingRunning = false;
  DateTime? _lastPosition;
  Future Function(List<Position>)? _callback;

  Future _process(List<Position> positions) async {
    _dataProcessor.add(() async {
      // Check if the position is older than the last position
      for (Position pos in positions) {
        if (_lastPosition == null ||
            pos.timestamp.isAfter(_lastPosition!) ||
            pos.timestamp.isAtSameMomentAs(_lastPosition!)) {
          _lastPosition = pos.timestamp;
        } else if (_lastPosition != null &&
            pos.timestamp.isBefore(_lastPosition!)) {
          throw Exception("Position is older than last position");
        }
      }

      await _callback!(positions);
    });
  }

  @override
  Future<void> init(BatteryUsageSetting options) async {
    TrackingService.init(options);
  }

  @override
  Future<bool> isRunning() {
    return Future.value(_trackingRunning);
  }

  @override
  Future<bool> start(BatteryUsageSetting setting,
      Future Function(List<Position>) callback) async {
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


    _lastPosition = null;
    this._callback = callback;
    TrackingService.getLocationUpdates((pos) async => await _process([pos]));
    _trackingId = await TrackingService.startLocationService(setting);
    await readCache();

    _trackingRunning = true;
    return true;
  }

  @override
  Future<bool> stop() async {
    if (!_trackingRunning) return false;
    this._callback = null;
    await TrackingService.stopLocationService(_trackingId);
    _trackingRunning = false;
    return true;
  }

  @override
  bool isProcessing() {
    return _dataProcessor.isProcessing;
  }

  @override
  Future readCache() async {
    Isar _cacheDb = await Databases.cache.getInstance();
    if (await _cacheDb.cacheObjects.where().isNotEmpty()) {
      List<Position> send = [];
      List<CacheObject> cached =
          await _cacheDb.cacheObjects.where().sortByTimestamp().findAll();
      send.addAll(cached.map((e) => Position.fromJson(jsonDecode(e.value))));
      await _cacheDb.writeTxn(() => _cacheDb.cacheObjects.where().deleteAll());
      Logging.info("Sending ${send.length} cached positions");
      await _process(send);
    }
  }
}
