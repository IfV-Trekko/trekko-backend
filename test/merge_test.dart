import 'package:trekko_backend/controller/trekko.dart';
import 'package:trekko_backend/controller/utils/trip_query.dart';
import 'package:trekko_backend/controller/utils/trip_builder.dart';
import 'package:trekko_backend/model/trip/trip.dart';
import 'package:fling_units/fling_units.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:isar/isar.dart';

import 'trekko_test_utils.dart';

void main() {
  late Trekko trekko;
  setUp(() async {
    trekko = await TrekkoTestUtils.initTrekko();
  });

  // Create 2 ways which are after each other
  test("Merge 2 ways", () async {
    Trip trip1 = TripBuilder()
        // stay for 1h
        .stay(Duration(hours: 1))
        // walk 500m
        .move(true, Duration(minutes: 10), 500.meters)
        .build();

    Trip trip2 =
        TripBuilder.withData(0, 0, trip1.getEndTime(), skipStayPoints: false)
            // stay for 1h
            .stay(Duration(hours: 1))
            // walk 500m
            .move(true, Duration(minutes: 10), 500.meters)
            .build();

    // Add the 2 ways to trekko
    int trip1Id = await trekko.saveTrip(trip1);
    int trip2Id = await trekko.saveTrip(trip2);

    Trip merge = await trekko
        .mergeTrips(TripQuery(trekko).andAnyId([trip1Id, trip2Id]).build());

    // Check start, end time and distance
    expect(merge.getStartTime(), trip1.getStartTime());
    expect(merge.getEndTime(), trip2.getEndTime());
    expect(merge.getDistance().as(meters).round(), 1000);

    // Check if there is no other trip
    List<Trip> trips = await trekko.getTripQuery().findAll();
    expect(trips.length, 1);
  });

  tearDownAll(() async => await TrekkoTestUtils.close(trekko));
}
