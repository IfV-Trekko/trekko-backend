import 'package:app_backend/controller/trekko.dart';
import 'package:app_backend/controller/utils/tracking_util.dart';
import 'package:app_backend/controller/utils/trip_builder.dart';
import 'package:app_backend/model/tracking_state.dart';
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
  setUpAll(() async {
    trekko = await TrekkoBuildUtils().loginOrRegister(email, password);
    await LocationBackgroundTracking.clearCache();
    await trekko.setTrackingState(TrackingState.running);
  });

  test("Analyze walk to shop and back", () async {
    List<LocationDto> walkToShopAndBack =
    // TripBuilder.withData(0, 0, skipStayPoints: false)
    // // stay for 10 min
    //     .stay(Duration(minutes: 10))
    //     .collect().map((e) => e.toPosition().toLocationDto()).toList();
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
        .collect().map((e) => e.toPosition().toLocationDto()).toList();

    for (LocationDto locationDto in walkToShopAndBack) {
      await LocationBackgroundTracking.callback(locationDto);
    }

    List<Trip> trips = await trekko.getTripQuery().findAll();
    expect(trips.length, 1);
    Trip trip = trips.first;
    expect(trip.legs.length, 2);
  });

  tearDownAll(() async {
    await LocationBackgroundTracking.clearCache();
    await TrekkoBuildUtils().close(trekko);
  });
}
