import 'package:isar/isar.dart';
import 'package:trekko_backend/controller/trekko.dart';
import 'package:trekko_backend/controller/utils/database_utils.dart';
import 'package:trekko_backend/controller/utils/tracking_service.dart';
import 'package:trekko_backend/model/cache_object.dart';
import 'package:trekko_backend/model/position.dart';

class TrackingTestUtil {
  static List<Function(Position)> positions = [];

  static Future<void> init() async {
    TrackingService.debug = true;
    TrackingService.debugCallback = onLocationSubscribe;
    await Databases.cache.getInstance(openIfFalse: true).then((value) async =>
        await value!.writeTxn(
            () async => await value.cacheObjects.where().deleteAll()));
  }

  static void onLocationSubscribe(Function(Position) locationCallback) {
    positions.add(locationCallback);
  }

  static Future<void> sendPositions(Trekko trekko,
      List<Position> position) async {
    for (Function(Position) positionCallback in positions) {
      for (Position pos in position) {
        positionCallback(pos);
      }
    }

    await waitForFinishProcessing(trekko);
  }

  static Future<void> waitForFinishProcessing(Trekko trekko) async {
    while (trekko.isProcessingLocationData()) {
      await Future.delayed(Duration(milliseconds: 100));
    }
  }
}
