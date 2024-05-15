import 'dart:async';

import 'package:permission_handler/permission_handler.dart';
import 'package:trekko_backend/controller/tracking/tracking.dart';
import 'package:trekko_backend/controller/utils/queued_executor.dart';
import 'package:trekko_backend/controller/utils/tracking_service.dart';
import 'package:trekko_backend/model/position.dart';
import 'package:trekko_backend/model/profile/battery_usage_setting.dart';

class CachedTracking implements Tracking {
  final QueuedExecutor _dataProcessor = QueuedExecutor();
  int _trackingId = 0;
  bool _trackingRunning = false;
  DateTime? _lastPosition;

  Future _process(Position position, Future Function(Position) callback) async {
    _dataProcessor.add(() async {
      // Check if the position is older than the last position
      if (_lastPosition != null &&
          position.timestamp.isBefore(_lastPosition!)) {
        throw Exception(
            "Positions must be added in chronological order. Newest timestamp: $_lastPosition, new timestamp: ${position.timestamp}");
      }

      _lastPosition = position.timestamp;
      await callback(position);
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

    _lastPosition = null;
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
  bool isProcessing() {
    return _dataProcessor.isProcessing;
  }
}
