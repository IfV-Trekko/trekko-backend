import 'package:trekko_backend/controller/builder/last_login_builder.dart';
import 'package:trekko_backend/controller/trekko.dart';
import 'package:trekko_backend/controller/utils/trip_builder.dart';
import 'package:trekko_backend/model/trip/trip.dart';
import 'package:fling_units/fling_units.dart';
import 'package:test/test.dart';

import 'trekko_test_utils.dart';

void main() {
  // A test, where a trekko will be used to test the persistance of the trips
  // So a trekko is created and a trip is saved, then trekko closed and reopened
  // And the trip is read again

  late Trekko trekko;
  late Trip trip;
  setUpAll(() async {
    trekko = await TrekkoTestUtils.initTrekko();
    trip = TripBuilder()
        .move_r(Duration(minutes: 10), 200.meters)
        .move_r(Duration(minutes: 10), 200.meters)
        .stay(Duration(minutes: 10))
        .move_r(Duration(minutes: 10), 200.meters)
        .build();
  });

  test("Save trip, init trekko and read", () async {
    int tripId = await trekko.saveTrip(trip);
    expect((await trekko.getTripQuery().andId(tripId).collectFirst()),
        isNotNull);
    await trekko.terminate();
    trekko = await LastLoginBuilder().build();
    Trip tripRead =
        (await trekko.getTripQuery().andId(tripId).collectFirst())!;
    expect(tripRead.calculateStartTime(), equals(trip.calculateStartTime()));
    expect(tripRead.calculateEndTime(), equals(trip.calculateEndTime()));
    expect(tripRead.calculateDistance(), equals(trip.calculateDistance()));
    expect(tripRead.calculateDuration(), equals(trip.calculateDuration()));
    expect(tripRead.calculateSpeed(), equals(trip.calculateSpeed()));
    expect(tripRead.calculateTransportTypes(), equals(trip.calculateTransportTypes()));
  });

  tearDownAll(() async {
    await TrekkoTestUtils.close(trekko);
  });
}
