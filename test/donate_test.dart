import 'package:app_backend/controller/trekko.dart';
import 'package:app_backend/controller/utils/trip_builder.dart';
import 'package:app_backend/model/trip/donation_state.dart';
import 'package:app_backend/model/trip/trip.dart';
import 'package:fling_units/fling_units.dart';
import 'package:isar/isar.dart';
import 'package:test/test.dart';

import 'trekko_build_utils.dart';

const String password = "1aA!hklj32r4hkjl324r";
const String email = "donate_test@profile_test.com";

void main() {
  late Trekko trekko;

  setUpAll(() async {
    trekko = await TrekkoBuildUtils().loginOrRegister(email, password);
  });

  test("Donate empty query", () async {
    try {
      await trekko.donate(trekko.getTripQuery().idEqualTo(-1).build());
      fail("Expected exception");
    } catch (e) {
      expect(e, isA<Exception>());
    }
  });

  test("Donate random trip and donate again", () async {
    Trip trip = TripBuilder().move_r(Duration(hours: 2), 200.meters).build();
    int tripId = await trekko.saveTrip(trip);
    await trekko.donate(trekko.getTripQuery().idEqualTo(tripId).build());

    trip = (await trekko.getTripQuery().idEqualTo(tripId).findFirst())!;
    expect(trip.donationState, DonationState.donated);

    try {
      await trekko.donate(trekko.getTripQuery().idEqualTo(tripId).build());
      fail("Expected exception");
    } catch (e) {
      expect(e, isA<Exception>());
    }
  });

  test("Donate random trip and revoke again", () async {
    Trip trip = TripBuilder().move_r(Duration(hours: 2), 200.meters).build();
    int tripId = await trekko.saveTrip(trip);
    await trekko.donate(trekko.getTripQuery().idEqualTo(tripId).build());

    trip = (await trekko.getTripQuery().idEqualTo(tripId).findFirst())!;
    expect(trip.donationState, DonationState.donated);

    await trekko.revoke(trekko.getTripQuery().idEqualTo(tripId).build());

    trip = (await trekko.getTripQuery().idEqualTo(tripId).findFirst())!;
    expect(trip.donationState, DonationState.notDonated);
  });

  test("Donate random trip and delete again", () async {
    Trip trip = TripBuilder().move_r(Duration(hours: 2), 200.meters).build();
    int tripId = await trekko.saveTrip(trip);
    await trekko.donate(trekko.getTripQuery().idEqualTo(tripId).build());

    trip = (await trekko.getTripQuery().idEqualTo(tripId).findFirst())!;
    expect(trip.donationState, DonationState.donated);

    await trekko.deleteTrip(trekko.getTripQuery().idEqualTo(tripId).build());
    expect(await trekko.getTripQuery().idEqualTo(tripId).build().count(), 0);
  });

  test("Donate multiple random trips and delete them again", () async {
    List<int> tripIds = [];
    var query = trekko.getTripQuery().filter().idEqualTo(-1);
    for (int i = 0; i < 10; i++) {
      Trip trip = TripBuilder().move_r(Duration(hours: 2), 200.meters).build();
      tripIds.add(await trekko.saveTrip(trip));
      query = query.or().idEqualTo(tripIds.last);
    }
    await trekko.donate(query.build());

    for (int tripId in tripIds) {
      Trip trip = (await trekko.getTripQuery().idEqualTo(tripId).findFirst())!;
      expect(trip.donationState, DonationState.donated);
    }

    await trekko.deleteTrip(query.build());
    expect(await query.count(), 0);
  });
}
