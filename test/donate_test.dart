import 'package:app_backend/controller/trekko.dart';
import 'package:app_backend/controller/utils/trip_builder.dart';
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

  test("Donate random trip", () async {
    Trip trip = TripBuilder().move_r(Duration(hours: 2), 200.meters).build();
    int tripId = await trekko.saveTrip(trip);
    await trekko.donate(trekko.getTripQuery().idEqualTo(tripId).build());
  });
}