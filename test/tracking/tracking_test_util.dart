import 'package:isar/isar.dart';
import 'package:trekko_backend/controller/trekko.dart';
import 'package:trekko_backend/controller/utils/database_utils.dart';
import 'package:trekko_backend/controller/utils/tracking_service.dart';
import 'package:trekko_backend/model/cache_object.dart';
import 'package:trekko_backend/model/position.dart';

class TrackingTestUtil {
  static List<Function(Position)> position_receiver = [];

  static Future<void> init() async {
    TrackingService.debug = true;
    TrackingService.debugCallback = onLocationSubscribe;
    print("Initialized tracking test util");
    await Databases.cache.getInstance(openIfNone: true).then((value) async =>
        await value!.writeTxn(
            () async => await value.cacheObjects.where().deleteAll()));
  }

  static void onLocationSubscribe(Function(Position) locationCallback) {
    position_receiver.add(locationCallback);
  }

  static Future<void> sendPositions(
      Trekko trekko, List<Position> positions) async {
    for (Function(Position) positionCallback in position_receiver) {
      for (Position pos in positions) {
        await positionCallback(pos);
      }
    }

    print("Finished sending positions; " +
        positions.length.toString() +
        " positions sent");
    await waitForFinishProcessing(trekko);
  }

  static Future<void> waitForFinishProcessing(Trekko trekko) async {
  while (trekko.isProcessingLocationData()) {
      await Future.delayed(Duration(milliseconds: 300));
    }
  }
}
