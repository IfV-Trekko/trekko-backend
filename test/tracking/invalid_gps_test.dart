import 'package:app_backend/controller/trekko.dart';
import 'package:app_backend/controller/utils/tracking_util.dart';
import 'package:app_backend/controller/utils/trip_builder.dart';
import 'package:app_backend/model/position.dart';
import 'package:app_backend/model/tracking_state.dart';
import 'package:app_backend/model/trip/tracked_point.dart';
import 'package:app_backend/model/trip/trip.dart';
import 'package:background_locator_2/location_dto.dart';
import 'package:fling_units/fling_units.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:isar/isar.dart';

import '../trekko_build_utils.dart';

const String password = "1aA!hklj32r4hkjl324r";
const String email = "invalid_gps_tracking_test@profile_test.com";

void main() {
  late Trekko trekko;
  setUp(() async {
    trekko = await TrekkoBuildUtils().loginOrRegister(email, password);
    await LocationBackgroundTracking.clearCache();
    await trekko.setTrackingState(TrackingState.running);
  });

  test("Analyze walk to shop and back with gps errors", () async {
    List<LocationDto> walkToShopAndBack =
        TripBuilder.withData(0, 0, skipStayPoints: false)
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
            .map((e) => e.toPosition().toLocationDto())
            .toList();

    // Obscure the GPS data. Choose random points and make the position off by over 100m
    List<Position> wrongPositions = [];
    for (int i = 0; i < walkToShopAndBack.length; i++) {
      if (i % 50 == 0) {
        Position toModify = Position.fromLocationDto(walkToShopAndBack[i]);
        double lat = toModify.latitude + 0.01;
        double lon = toModify.longitude * 0.01;
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
        walkToShopAndBack[i] = modified.toLocationDto();
        wrongPositions.add(modified);
      }
    }

    for (LocationDto locationDto in walkToShopAndBack) {
      await LocationBackgroundTracking.callback(locationDto);
    }

    // Wait for the trip to be analyzed
    await Future.delayed(Duration(seconds: 3));

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

  tearDown(() async {
    await LocationBackgroundTracking.clearCache();
    await TrekkoBuildUtils().close(trekko);
  });
}
