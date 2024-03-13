import 'package:app_backend/controller/analysis/average.dart';
import 'package:app_backend/controller/analysis/reductions.dart';
import 'package:app_backend/controller/trekko.dart';
import 'package:app_backend/controller/utils/trip_builder.dart';
import 'package:app_backend/model/trip/leg.dart';
import 'package:app_backend/model/trip/transport_type.dart';
import 'package:app_backend/model/trip/trip.dart';
import 'package:fling_units/fling_units.dart';
import 'package:isar/isar.dart';
import 'package:test/test.dart';

import '../trekko_build_utils.dart';

const String password = "1aA!hklj32r4hkjl324r";
const String email = "profile_test113@profile_test.com";

Future<void> checkTrip(
    Trekko trekko, int tripId, Distance distance, Duration duration) async {
  var query = trekko.getTripQuery().idEqualTo(tripId).build();
  double? calculatedDistance = await trekko
      .analyze(
          query, (t) => [t.getDistance().as(kilo.meters)], DoubleReduction.SUM)
      .first;
  double? calculatedDuration = (await trekko
      .analyze(query, (t) => [t.calculateDuration().inSeconds.toDouble()],
          DoubleReduction.SUM)
      .first);
  double? calculatedSpeed = await trekko
      .analyze(query, (t) => [t.calculateSpeed().as(kilo.meters, hours)],
          AverageCalculation())
      .first;

  expect(calculatedDistance!.round(), equals(distance.as(kilo.meters)));
  expect(calculatedDuration, equals(duration.inSeconds));
  expect(
      calculatedSpeed!.round(),
      equals(equals(distance
          .per(duration.inHours.hours)
          .as(kilo.meters, hours)
          .round())));
}

void main() {
  late Trekko trekko;
  setUpAll(() async =>
      trekko = await TrekkoBuildUtils().loginOrRegister(email, password));

  test("Analyze trip with one leg", () async {
    Trip trip = TripBuilder()
        .stay(Duration(hours: 1))
        .move_r(Duration(hours: 1), 100.meters)
        .stay(Duration(minutes: 30))
        .move_r(Duration(minutes: 30), 900.meters)
        .build();

    int tripId = await trekko.saveTrip(trip);
    await checkTrip(trekko, tripId, 1.kilo.meters, Duration(hours: 2));
  });

  test("Analyze trip with 2 legs", () async {
    Trip trip = TripBuilder()
        .stay(Duration(hours: 1))
        .move_r(Duration(hours: 1), 100.meters)
        .stay(Duration(minutes: 30))
        .move_r(Duration(minutes: 30), 900.meters)
        .leg()
        .stay(Duration(hours: 1))
        .move_r(Duration(hours: 1), 100.meters)
        .stay(Duration(minutes: 30))
        .move_r(Duration(minutes: 30), 900.meters)
        .build();

    int tripId = await trekko.saveTrip(trip);
    await checkTrip(trekko, tripId, 2.kilo.meters, Duration(hours: 5));
  });

  test("Analyze transport type data with not trip in it", () async {
    var query = trekko
        .getTripQuery()
        .filter()
        .legsElement((q) => q.transportTypeEqualTo(TransportType.other));
    var transportTypeData = await trekko
        .analyze(query.build(), (t) => [t.getDistance().as(kilo.meters)],
            DoubleReduction.SUM)
        .first;
    expect(transportTypeData, equals(null));
  });

  tearDownAll(() async => await TrekkoBuildUtils().close(trekko));
}
