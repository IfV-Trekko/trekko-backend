import 'package:app_backend/controller/wrapper/analyzing_trip_wrapper.dart';
import 'package:app_backend/controller/wrapper/trip_wrapper.dart';
import 'package:app_backend/model/trip/tracked_point.dart';
import 'package:app_backend/model/trip/transport_type.dart';
import 'package:app_backend/model/trip/trip.dart';
import 'package:fling_units/fling_units.dart';
import 'package:test/test.dart';

import 'wrapper_test_utils.dart';

List<TrackedPoint> walk_to_shop = [
  // stay for 1h
  ...generateStay(0, 0, DateTime.now(), Duration(hours: 1)),
  // walk 500m
  ...generateLeg(0, 0, Duration(minutes: 10), 500.meters.per(10.minutes),
      DateTime.now().add(Duration(hours: 1))),
  // stay for 5min
  ...generateStay(
      0,
      500 * degreesPerMeter,
      DateTime.now().add(Duration(hours: 1, minutes: 10)),
      Duration(minutes: 5)),
  // walk 500m back
  ...generateLeg(
      0,
      0,
      Duration(minutes: 10),
      500.meters.per(10.minutes),
      DateTime.now().add(Duration(hours: 1, minutes: 15))),
  // stay for 1h
  ...generateStay(
      0,
      0,
      DateTime.now().add(Duration(hours: 1, minutes: 25)),
      Duration(hours: 1)),
];

void main() {
  late TripWrapper tripWrapper;
  setUpAll(() async {
    tripWrapper = AnalyzingTripWrapper();
  });

  test("Analyze walk to shop", () async {
    for (TrackedPoint point in walk_to_shop) {
      await tripWrapper.add(point.toPosition());
    }
    double probability = await tripWrapper.calculateEndProbability();
    expect(probability, greaterThan(0.9));

    Trip wrapped = await tripWrapper.get();
    expect(wrapped.legs.length, equals(2));
    expect(wrapped.legs[0].getDistance().as(kilo.meters).round(), equals(1));
    expect(wrapped.legs[0].getDuration().inMinutes, equals(10));
    expect(wrapped.legs[0].getSpeed().as(kilo.meters, hours).round(), equals(6));
    expect(wrapped.legs[0].transportType, equals(TransportType.by_foot));

    expect(wrapped.legs[1].getDistance().as(kilo.meters).round(), equals(1));
    expect(wrapped.legs[1].getDuration().inMinutes, equals(10));
    expect(wrapped.legs[1].getSpeed().as(kilo.meters, hours).round(), equals(6));
    expect(wrapped.legs[1].transportType, equals(TransportType.by_foot));
  });
}
