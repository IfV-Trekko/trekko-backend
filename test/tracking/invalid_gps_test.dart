import 'package:trekko_backend/controller/trekko.dart';
import 'package:trekko_backend/model/tracking/position.dart';
import 'package:trekko_backend/model/tracking_state.dart';
import 'package:trekko_backend/model/trip/tracked_point.dart';
import 'package:trekko_backend/model/trip/trip.dart';
import 'package:flutter_test/flutter_test.dart';

import '../trekko_test_utils.dart';
import '../utils/tracking_test_util.dart';

void main() {
  late Trekko trekko;
  setUp(() async {
    trekko = await TrekkoTestUtils.initTrekko();
    await trekko.setTrackingState(TrackingState.running);
  });

  test("Analyze walk to shop and back with gps errors", () async {
    // Obscure the GPS data. Choose random points and make the position off by over 100m
    List<Position> wrongPositions = [];
    for (int i = 0; i < walkToShopAndBack.length; i++) {
      if (i % 50 == 0 && walkToShopAndBack[i] is Position) {
        Position toModify = walkToShopAndBack[i] as Position;
        double lat = toModify.latitude + 0.001;
        double lon = toModify.longitude + 0.001;
        Position modified = Position(
          latitude: lat,
          longitude: lon,
          accuracy: 100,
          timestamp: toModify.timestamp,
        );
        walkToShopAndBack[i] = modified;
        wrongPositions.add(modified);
      }
    }

    await TrackingTestUtil.sendData(trekko, walkToShopAndBack);

    List<Trip> trips = await trekko.getTripQuery().collect();
    // Check if the wrong positions are in the trips
    List<TrackedPoint> allPositions = trips
        .expand((trip) => trip.legs.expand((leg) => leg.trackedPoints))
        .toList();
    for (Position wrongPosition in wrongPositions) {
      for (TrackedPoint point in allPositions) {
        expect(
          point.latitude == wrongPosition.latitude &&
              point.longitude == wrongPosition.longitude &&
              point.timestamp == wrongPosition.timestamp,
          isFalse,
          reason:
              "Wrong position found in trip; ts: " + point.timestamp.toString(),
        );
      }
    }
  });

  tearDown(() async {
    await TrekkoTestUtils.close(trekko);
  });
}
