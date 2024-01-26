import 'package:app_backend/controller/analysis/reductions.dart';
import 'package:app_backend/controller/trekko.dart';
import 'package:app_backend/model/trip/donation_state.dart';
import 'package:app_backend/model/trip/leg.dart';
import 'package:app_backend/model/trip/tracked_point.dart';
import 'package:app_backend/model/trip/transport_type.dart';
import 'package:app_backend/model/trip/trip.dart';
import 'package:fling_units/fling_units.dart';
import 'package:geolocator/geolocator.dart';
import 'package:isar/isar.dart';
import 'package:test/test.dart';

import 'trekko_build_utils.dart';

const String password = "1aA!hklj32r4hkjl324r";
const String email = "profile_test113@profile_test.com";

List<Trip> trips = [
  Trip(
      donationState: DonationState.donated,
      comment: null,
      purpose: null,
      legs: [
        Leg.withData(TransportType.bicycle, [
          TrackedPoint.withData(0, 0, 15, DateTime.now()),
          TrackedPoint.withData(
              0, 1, 15, DateTime.now().add(Duration(hours: 1))),
          TrackedPoint.withData(
              0, 2, 15, DateTime.now().add(Duration(hours: 2))),
          TrackedPoint.withData(
              0, 3, 15, DateTime.now().add(Duration(hours: 3))),
        ]),
      ]),
  Trip(
      donationState: DonationState.donated,
      comment: null,
      purpose: null,
      legs: [
        Leg.withData(TransportType.bicycle, [
          TrackedPoint.withData(0, 0, 15, DateTime.now()),
          TrackedPoint.withData(
              0, 1, 15, DateTime.now().add(Duration(hours: 2))),
          TrackedPoint.withData(
              0, 2, 15, DateTime.now().add(Duration(hours: 4))),
          TrackedPoint.withData(
              0, 3, 15, DateTime.now().add(Duration(hours: 6))),
        ]),
        Leg.withData(TransportType.car, [
          TrackedPoint.withData(
              0, 0, 15, DateTime.now().add(Duration(hours: 6))),
          TrackedPoint.withData(
              0, 1, 15, DateTime.now().add(Duration(hours: 8))),
          TrackedPoint.withData(
              0, 2, 15, DateTime.now().add(Duration(hours: 10))),
          TrackedPoint.withData(
              0, 3, 15, DateTime.now().add(Duration(hours: 12))),
        ]),
      ]),
];

void main() {
  late Trekko trekko;
  setUpAll(() async =>
      trekko = await TrekkoBuildUtils().loginOrRegister(email, password));

  double METERS_PER_DEGREE = Geolocator.distanceBetween(0, 0, 0, 1);
  test("Analyze first trip", () async {
    int tripId = await trekko.saveTrip(trips[0]);
    Distance? distance = await trekko
        .analyze(trekko.getTripQuery().idEqualTo(tripId).build(),
            (t) => t.getDistance(), DistanceReduction.SUM)
        .first;
    expect(distance!.as(kilo.meters).round(),
        equals(meters(3 * METERS_PER_DEGREE).as(kilo.meters).round()));

    Duration? duration = await trekko
        .analyze(trekko.getTripQuery().idEqualTo(tripId).build(),
            (t) => t.getDuration(), DurationReduction.SUM)
        .first;
    expect(duration!.inHours, equals(3));

    DerivedMeasurement<Measurement<Distance>, Measurement<Time>>? speed =
        await trekko
            .analyze(trekko.getTripQuery().idEqualTo(tripId).build(),
                (t) => t.getSpeed(), SpeedReduction.AVERAGE)
            .first;
    expect(
        speed,
        equals(meters(3 * METERS_PER_DEGREE)
            .per(duration.inSeconds.seconds)));
  });

  test("Analyze second trip", () async {
    int tripId = await trekko.saveTrip(trips[1]);
    Distance? distance = await trekko
        .analyze(trekko.getTripQuery().idEqualTo(tripId).build(),
            (t) => t.getDistance(), DistanceReduction.SUM)
        .first;
    expect(distance!.as(kilo.meters).round(),
        equals(meters(6 * METERS_PER_DEGREE).as(kilo.meters).round()));

    Duration? duration = await trekko
        .analyze(trekko.getTripQuery().idEqualTo(tripId).build(),
            (t) => t.getDuration(), DurationReduction.SUM)
        .first;
    expect(duration!.inHours, equals(12));

    DerivedMeasurement<Measurement<Distance>, Measurement<Time>>? speed =
        await trekko
            .analyze(trekko.getTripQuery().idEqualTo(tripId).build(),
                (t) => t.getSpeed(), SpeedReduction.AVERAGE)
            .first;
    expect(
        speed,
        equals(meters(6 * METERS_PER_DEGREE)
            .per(duration.inSeconds.seconds)));
  });

  tearDownAll(() async => await trekko.terminate());
}
