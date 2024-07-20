import 'package:trekko_backend/controller/trekko.dart';
import 'package:trekko_backend/controller/utils/trip_builder.dart';
import 'package:trekko_backend/controller/utils/trip_query.dart';
import 'package:trekko_backend/model/trip/donation_state.dart';
import 'package:trekko_backend/model/trip/trip.dart';
import 'package:fling_units/fling_units.dart';
import 'package:test/test.dart';

import 'utils/trekko_test_utils.dart';

void main() {
  late Trekko trekko;

  setUpAll(() async {
    trekko = await TrekkoTestUtils.initTrekko(online: true);
  });

  test("Donate empty query", () async {
    try {
      await trekko.donate(trekko.getTripQuery().andId(-1));
      fail("Expected exception");
    } catch (e) {
      expect(e, isA<Exception>());
    }
  });

  test("Donate random trip and donate again", () async {
    Trip trip = TripBuilder().move_r(Duration(hours: 2), 200.meters).build();
    int tripId = await trekko.saveTrip(trip);
    await trekko.donate(trekko.getTripQuery().andId(tripId));

    trip = (await trekko.getTripQuery().andId(tripId).collectFirst())!;
    expect(trip.donationState, DonationState.donated);

    try {
      await trekko.donate(trekko.getTripQuery().andId(tripId));
      fail("Expected exception");
    } catch (e) {
      expect(e, isA<Exception>());
    }
  });

  test("Donate random trip and revoke again", () async {
    Trip trip = TripBuilder().move_r(Duration(hours: 2), 200.meters).build();
    int tripId = await trekko.saveTrip(trip);
    await trekko.donate(trekko.getTripQuery().andId(tripId));

    trip = (await trekko.getTripQuery().andId(tripId).collectFirst())!;
    expect(trip.donationState, DonationState.donated);

    await trekko.revoke(trekko.getTripQuery().andId(tripId));

    trip = (await trekko.getTripQuery().andId(tripId).collectFirst())!;
    expect(trip.donationState, DonationState.notDonated);
  });

  test("Donate random trip and delete again", () async {
    Trip trip = TripBuilder().move_r(Duration(hours: 2), 200.meters).build();
    int tripId = await trekko.saveTrip(trip);
    await trekko.donate(trekko.getTripQuery().andId(tripId));

    trip = (await trekko.getTripQuery().andId(tripId).collectFirst())!;
    expect(trip.donationState, DonationState.donated);

    await trekko.deleteTrip(trekko.getTripQuery().andId(tripId));
    expect(await trekko.getTripQuery().andId(tripId).count(), 0);
  });

  test("Donate multiple random trips and delete them again in one query",
      () async {
    List<int> tripIds = [];
    for (int i = 0; i < 10; i++) {
      Trip trip = TripBuilder().move_r(Duration(hours: 2), 200.meters).build();
      tripIds.add(await trekko.saveTrip(trip));
    }
    TripQuery query = trekko.getTripQuery().andAnyId(tripIds);
    await trekko.donate(query);

    for (int tripId in tripIds) {
      Trip trip = (await trekko.getTripQuery().andId(tripId).collectFirst())!;
      expect(trip.donationState, DonationState.donated);
    }

    await trekko.deleteTrip(query);
    expect(await query.count(), 0);
  });

  test("Donate multiple random trips and delete them again in multiple queries",
      () async {
    List<int> tripIds = [];
    for (int i = 0; i < 10; i++) {
      Trip trip = TripBuilder().move_r(Duration(hours: 2), 200.meters).build();
      tripIds.add(await trekko.saveTrip(trip));
    }
    TripQuery query = trekko.getTripQuery().andAnyId(tripIds);
    await trekko.donate(query);

    for (int tripId in tripIds) {
      Trip trip = (await trekko.getTripQuery().andId(tripId).collectFirst())!;
      expect(trip.donationState, DonationState.donated);
    }

    for (int tripId in tripIds) {
      await trekko.deleteTrip(trekko.getTripQuery().andId(tripId));
      expect(await trekko.getTripQuery().andId(tripId).count(), 0);
    }
  });

  tearDownAll(() async {
    await TrekkoTestUtils.close(trekko);
  });
}
