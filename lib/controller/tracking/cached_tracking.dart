import 'dart:async';
import 'dart:convert';

import 'package:isar/isar.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:trekko_backend/controller/tracking/tracking.dart';
import 'package:trekko_backend/controller/utils/database_utils.dart';
import 'package:trekko_backend/controller/utils/logging.dart';
import 'package:trekko_backend/controller/utils/queued_executor.dart';
import 'package:trekko_backend/controller/tracking/tracking_service.dart';
import 'package:trekko_backend/model/profile/battery_usage_setting.dart';
import 'package:trekko_backend/model/tracking/cache/cache_object.dart';
import 'package:trekko_backend/model/tracking/cache/raw_phone_data_type.dart';
import 'package:trekko_backend/model/tracking/raw_phone_data.dart';

class CachedTracking implements Tracking {
  final QueuedExecutor _dataProcessor = QueuedExecutor();
  int _trackingId = 0;
  bool _trackingRunning = false;
  Future Function(Iterable<RawPhoneData>)? _callback;

  _process(Iterable<RawPhoneData> positions) {
    _dataProcessor.add(() async => await _callback!(positions));
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
      Future Function(Iterable<RawPhoneData>) callback) async {
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

    this._callback = callback;
    await readCache();
    TrackingService.getLocationUpdates(_process);
    _trackingId = await TrackingService.startLocationService(setting);
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
      List<RawPhoneData> send = [];
      List<CacheObject> cached =
          await _cacheDb.cacheObjects.where().sortByTimestamp().findAll();
      send.addAll(
          cached.map((e) => RawPhoneDataType.parseData(jsonDecode(e.value))));
      Logging.info("Sending ${send.length} cached data points");
      await _cacheDb.writeTxn(() => _cacheDb.cacheObjects.where().deleteAll());
      _process(send);
    }
  }
}
