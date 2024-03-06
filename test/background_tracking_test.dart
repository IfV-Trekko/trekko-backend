import 'package:app_backend/controller/trekko.dart';
import 'package:app_backend/controller/utils/tracking_util.dart';
import 'package:app_backend/controller/utils/trip_builder.dart';
import 'package:app_backend/model/tracking_state.dart';
import 'package:app_backend/model/trip/transport_type.dart';
import 'package:app_backend/model/trip/trip.dart';
import 'package:background_locator_2/location_dto.dart';
import 'package:fling_units/fling_units.dart';
import 'package:isar/isar.dart';
import 'package:test/test.dart';

import 'trekko_build_utils.dart';

const String password = "1aA!hklj32r4hkjl324r";
const String email = "background_tracking_test@profile_test.com";

void main() {
  late Trekko trekko;
  setUp(() async {
    trekko = await TrekkoBuildUtils().loginOrRegister(email, password);
    await LocationBackgroundTracking.clearCache();
    await trekko.setTrackingState(TrackingState.running);
  });

  test("Analyze walk to shop and back", () async {
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

    for (LocationDto locationDto in walkToShopAndBack) {
      await LocationBackgroundTracking.callback(locationDto);
    }

    // Wait for the trip to be analyzed
    await Future.delayed(Duration(seconds: 3));

    List<Trip> trips = await trekko.getTripQuery().findAll();
    expect(trips.length, 1);
    Trip trip = trips.first;
    expect(trip.legs.length, 2);
    expect(trip.legs.first.transportType, TransportType.by_foot);
    expect(trip.legs.last.transportType, TransportType.by_foot);
  });

  test("Analyze walk to shop and back and only stay for 90 sec", () async {
    List<LocationDto> walkToShopAndBack =
        TripBuilder.withData(0, 0, skipStayPoints: false)
            // stay for 1h
            .stay(Duration(hours: 1))
            // walk 500m
            .move(true, Duration(minutes: 10), 500.meters)
            // stay for 1min
            .stay(Duration(seconds: 90))
            // walk 500m back
            .move(false, Duration(minutes: 10), 500.meters)
            // stay for 1h
            .stay(Duration(minutes: 20))
            .collect()
            .map((e) => e.toPosition().toLocationDto())
            .toList();

    for (LocationDto locationDto in walkToShopAndBack) {
      await LocationBackgroundTracking.callback(locationDto);
    }

    // Wait for the trip to be analyzed
    await Future.delayed(Duration(seconds: 3));

    List<Trip> trips = await trekko.getTripQuery().findAll();
    expect(trips.length, 0);
  });

  test("Analyze walk to shop and back and only stay 15 min at the end",
      () async {
    List<LocationDto> walkToShopAndBack =
        TripBuilder.withData(0, 0, skipStayPoints: false)
            // stay for 1h
            .stay(Duration(hours: 1))
            // walk 500m
            .move(true, Duration(minutes: 10), 500.meters)
            // stay for 2min
            .stay(Duration(minutes: 2))
            // walk 500m back
            .move(false, Duration(minutes: 10), 500.meters)
            // stay for 15m
            .stay(Duration(minutes: 15))
            .collect()
            .map((e) => e.toPosition().toLocationDto())
            .toList();

    for (LocationDto locationDto in walkToShopAndBack) {
      await LocationBackgroundTracking.callback(locationDto);
    }

    // Wait for the trip to be analyzed
    await Future.delayed(Duration(seconds: 3));

    List<Trip> trips = await trekko.getTripQuery().findAll();
    expect(trips.length, 0);
  });

  tearDown(() async {
    await LocationBackgroundTracking.clearCache();
    await TrekkoBuildUtils().close(trekko);
  });
}
