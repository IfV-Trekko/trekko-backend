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
  final List<Position> _initialPositions = [];
  late StreamController<Position> _positionStream;
  int _trackingId = 0;
  bool _trackingRunning = false;

  Future<List<Position>> _readCache() {
    return _cache.cacheObjects.where().sortByTimestamp().findAll().then(
        (value) =>
            value.map((e) => Position.fromJson(jsonDecode(e.value))).toList());
  }

  void _processLocation(Position position) {
    _positionStream.add(position);
  }

  void _locationCallback(Position position) async {
    _dataProcessor.add(() async => _processLocation(position));
  }

  @override
  Future<void> init(BatteryUsageSetting options) async {
    _positionStream = StreamController<Position>.broadcast();
    _cache = (await Databases.cache.getInstance());
    _initialPositions.addAll(await _readCache());
    _positionStream.onListen = () async {
      Logging.info("Processing ${_initialPositions.length} initial positions");
      for (Position pos in _initialPositions) {
        _processLocation(pos);
      }
      _initialPositions.clear();
    };

    TrackingService.init(options);
  }

  @override
  Future<bool> isRunning() {
    return Future.value(_trackingRunning);
  }

  @override
  Stream<Position> track() {
    return _positionStream.stream;
  }

  @override
  Future<bool> start(BatteryUsageSetting setting) async {
    for (Permission perm in Tracking.perms) {
      PermissionStatus status = await perm.status;
      if (status != PermissionStatus.granted) {
        status = await perm.request();
        if (status != PermissionStatus.granted) {
          return false;
        }
      }
    }

    TrackingService.getLocationUpdates(_locationCallback);
    _trackingId = await TrackingService.startLocationService(setting);
    _trackingRunning = true;
    return true;
  }

  @override
  Future<bool> stop() async {
    if (!_trackingRunning) return false;
    if (_dataProcessor.isProcessing)
      throw Exception("Data processing is still running");

    TrackingService.stopLocationService(_trackingId);
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
