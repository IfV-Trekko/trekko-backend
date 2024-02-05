import 'package:app_backend/controller/builder/last_login_builder.dart';
import 'package:app_backend/controller/trekko.dart';
import 'package:app_backend/controller/utils/trip_builder.dart';
import 'package:app_backend/model/trip/trip.dart';
import 'package:fling_units/fling_units.dart';
import 'package:isar/isar.dart';
import 'package:test/test.dart';

import 'trekko_build_utils.dart';

const String password = "1aA!hklj32r4hkjl324r";
const String email = "persistance_test@profile_test.com";

void main() {
  // A test, where a trekko will be used to test the persistance of the trips
  // So a trekko is created and a trip is saved, then trekko closed and reopened
  // And the trip is read again

  late Trekko trekko;
  late Trip trip;
  setUpAll(() async {
    trekko = await TrekkoBuildUtils().loginOrRegister(email, password);
    trip = TripBuilder()
        .move_r(Duration(minutes: 10), 200.meters)
        .move_r(Duration(minutes: 10), 200.meters)
        .stay(Duration(minutes: 10))
        .move_r(Duration(minutes: 10), 200.meters)
        .build();
  });

  test("Save trip, init trekko and read", () async {
    int tripId = await trekko.saveTrip(trip);
    expect((await trekko.getTripQuery().filter().idEqualTo(tripId).findFirst()),
        isNotNull);
    await trekko.terminate();
    trekko = await LastLoginBuilder().build();
    Trip tripRead =
        (await trekko.getTripQuery().filter().idEqualTo(tripId).findFirst())!;
    expect(tripRead.getStartTime(), equals(trip.getStartTime()));
    expect(tripRead.getEndTime(), equals(trip.getEndTime()));
    expect(tripRead.getDistance(), equals(trip.getDistance()));
    expect(tripRead.calculateDuration(), equals(trip.calculateDuration()));
    expect(tripRead.calculateSpeed(), equals(trip.calculateSpeed()));
    expect(tripRead.getTransportTypes(), equals(trip.getTransportTypes()));
  });

  tearDownAll(() async {
    await TrekkoBuildUtils().close(trekko);
  });
}
