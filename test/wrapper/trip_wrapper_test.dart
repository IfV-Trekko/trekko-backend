import 'package:app_backend/controller/wrapper/analyzing_trip_wrapper.dart';
import 'package:app_backend/controller/wrapper/trip_wrapper.dart';
import 'package:app_backend/model/trip/tracked_point.dart';
import 'package:app_backend/model/trip/transport_type.dart';
import 'package:app_backend/model/trip/trip.dart';
import 'package:fling_units/fling_units.dart';
import 'package:test/test.dart';

import '../trip_gen_utils.dart';

void main() {
  late TripWrapper tripWrapper;
  setUp(() async {
    tripWrapper = AnalyzingTripWrapper();
  });

  test("Analyze walk to shop and back", () async {
    List<TrackedPoint> walkToShopAndBack = [
      // stay for 1h
      ...stay(Duration(hours: 1)),
      // walk 500m
      ...move(true, Duration(minutes: 10), 500.meters),
      // stay for 5min
      ...stay(Duration(minutes: 5)),
      // walk 500m back
      ...move(false, Duration(minutes: 10), 500.meters),
      // stay for 1h
      ...stay(Duration(hours: 1)),
    ];

    for (TrackedPoint point in walkToShopAndBack) {
      await tripWrapper.add(point.toPosition());
    }
    double probability = await tripWrapper.calculateEndProbability();
    expect(probability, greaterThan(0.9));

    Trip wrapped = await tripWrapper.get();
    expect(wrapped.legs.length, equals(2));
    expect(wrapped.legs[0].getDistance().as(kilo.meters).round(), equals(1));
    expect(wrapped.legs[0].getDuration().inMinutes, equals(10));
    expect(
        wrapped.legs[0].getSpeed().as(kilo.meters, hours).round(), equals(6));
    expect(wrapped.legs[0].transportType, equals(TransportType.by_foot));

    expect(wrapped.legs[1].getDistance().as(kilo.meters).round(), equals(1));
    expect(wrapped.legs[1].getDuration().inMinutes, equals(10));
    expect(
        wrapped.legs[1].getSpeed().as(kilo.meters, hours).round(), equals(6));
    expect(wrapped.legs[1].transportType, equals(TransportType.by_foot));
  });

  test("Staying at the same location: no trip", () async {
    List<TrackedPoint> points = [
      ...stay(Duration(hours: 1)),
      ...stay(Duration(hours: 1)),
      ...stay(Duration(hours: 1)),
    ];
    for (TrackedPoint point in points) {
      await tripWrapper.add(point.toPosition());
    }
    double probability = await tripWrapper.calculateEndProbability();
    expect(probability, lessThan(0.1));
  });
}
