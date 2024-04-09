import 'package:trekko_backend/controller/trekko.dart';
import 'package:trekko_backend/controller/utils/trip_builder.dart';
import 'package:trekko_backend/model/position.dart';
import 'package:trekko_backend/model/tracking_state.dart';
import 'package:trekko_backend/model/trip/tracked_point.dart';
import 'package:trekko_backend/model/trip/trip.dart';
import 'package:fling_units/fling_units.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:isar/isar.dart';

import '../trekko_test_utils.dart';
import 'tracking_test_util.dart';

void main() {
  late Trekko trekko;
  setUp(() async {
    trekko = await TrekkoTestUtils.initTrekko();
    await trekko.setTrackingState(TrackingState.running);
  });

  test("Analyze walk to shop and back with gps errors", () async {
    List<Position> walkToShopAndBack =
        TripBuilder()
            // stay for 1h
            .stay(Duration(hours: 1))
            // walk 500m
            .move(true, Duration(minutes: 10), 500.meters)
            // stay for 5min
            .stay(Duration(minutes: 5))
            // walk 500m back
            .move(false, Duration(minutes: 10), 500.meters)
            // stay for 1h
            .stay(Duration(hours: 1))
            .collect()
            .map((e) => e.toPosition())
            .toList();

    // Obscure the GPS data. Choose random points and make the position off by over 100m
    List<Position> wrongPositions = [];
    for (int i = 0; i < walkToShopAndBack.length; i++) {
      if (i % 50 == 0) {
        Position toModify = walkToShopAndBack[i];
        double lat = toModify.latitude + 0.001;
        double lon = toModify.longitude + 0.001;
        Position modified = Position(
          latitude: lat,
          longitude: lon,
          accuracy: toModify.accuracy,
          altitude: toModify.altitude,
          altitudeAccuracy: toModify.altitudeAccuracy,
          speed: toModify.speed,
          speedAccuracy: toModify.speedAccuracy,
          heading: toModify.heading,
          headingAccuracy: toModify.headingAccuracy,
          timestamp: toModify.timestamp,
        );
        walkToShopAndBack[i] = modified;
        wrongPositions.add(modified);
      }
    }

    await TrackingTestUtil.sendPositions(trekko, walkToShopAndBack);

    List<Trip> trips = await trekko.getTripQuery().findAll();
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
          isFalse, reason: "Wrong position found in trip; ts: " + point.timestamp.toString(),
        );
      }
    }
  });

  test("Analyze small jump in coordinates", () async {
    List<Position> walkToShopAndBack =
    TripBuilder()
        .stay(Duration(hours: 1))
        .move(true, Duration(seconds: 10), 400.meters)
        .move(false, Duration(seconds: 10), 400.meters)
        .stay(Duration(hours: 1))
        .collect()
        .map((e) => e.toPosition())
        .toList();

    await TrackingTestUtil.sendPositions(trekko, walkToShopAndBack);

    // Check if the wrong positions are in the trips
    expect(await trekko.getTripQuery().isEmpty(), true);
  });

  tearDown(() async {
    await TrekkoTestUtils.close(trekko);
  });
}
