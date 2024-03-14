import 'package:app_backend/controller/trekko.dart';
import 'package:app_backend/controller/utils/query_util.dart';
import 'package:app_backend/controller/utils/trip_builder.dart';
import 'package:app_backend/model/trip/tracked_point.dart';
import 'package:app_backend/model/trip/transport_type.dart';
import 'package:app_backend/model/trip/trip.dart';
import 'package:fling_units/fling_units.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:isar/isar.dart';

import 'trekko_build_utils.dart';

const String password = "1aA!hklj32r4hkjl324r";
const String email = "merge_test@profile_test.com";

void main() {
  late Trekko trekko;
  setUp(() async {
    trekko = await TrekkoBuildUtils().loginOrRegister(email, password);
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

    Trip merge = await trekko.mergeTrips(QueryUtil(trekko).buildIdsOr([trip1Id, trip2Id]));

    // Check start, end time and distance
    expect(merge.getStartTime(), trip1.getStartTime());
    expect(merge.getEndTime(), trip2.getEndTime());
    expect(merge.getDistance().as(meters).round(), 1000);

    // Check if there is no other trip
    List<Trip> trips = await trekko.getTripQuery().findAll();
    expect(trips.length, 1);
  });

  tearDownAll(() async => await TrekkoBuildUtils().close(trekko));
}
