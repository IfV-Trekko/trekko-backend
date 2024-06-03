import 'package:trekko_backend/controller/utils/trip_builder.dart';
import 'package:trekko_backend/controller/wrapper/analyzer/analyzing_trip_wrapper.dart';
import 'package:trekko_backend/controller/wrapper/analyzer/trip_wrapper.dart';
import 'package:trekko_backend/controller/wrapper/wrapper_result.dart';
import 'package:trekko_backend/model/trip/tracked_point.dart';
import 'package:trekko_backend/model/trip/trip.dart';
import 'package:fling_units/fling_units.dart';
import 'package:test/test.dart';

import '../trekko_test_utils.dart';

void main() {
  late TripWrapper tripWrapper;
  setUp(() async {
    await TrekkoTestUtils.init();
    tripWrapper = AnalyzingTripWrapper([]);
  });

  test("Analyze walk to shop and back", () async {
    List<TrackedPoint> walkToShopAndBack = TripBuilder()
        // stay for 1h
        .stay(Duration(hours: 1))
        // walk 500m
        .move(true, Duration(minutes: 10), 500.meters)
        // stay for 5min
        .stay(Duration(minutes: 5))
        // walk 500m back
        .move(false, Duration(minutes: 10), 500.meters)
        // stay for 1h
        .stay(Duration(hours: 1))
        .collect();

    await tripWrapper.add(walkToShopAndBack.map((e) => e.toPosition()));
    WrapperResult result = await tripWrapper.get();
    expect(result.confidence, greaterThan(0.9));

    Trip wrapped = result.result;
    expect(wrapped.legs.length, equals(2));
    expect(wrapped.calculateDistance().as(meters), inInclusiveRange(700, 1000));
    expect(wrapped.calculateDuration().inMinutes, inInclusiveRange(20, 25));
    expect(wrapped.calculateSpeed().as(kilo.meters, hours).round(),
        inInclusiveRange(1, 3));
  });

  test("Staying at the same location: no trip", () async {
    List<TrackedPoint> points = TripBuilder()
        // stay for 1h
        .stay(Duration(hours: 1))
        // stay for 1h
        .stay(Duration(hours: 1))
        // stay for 1h
        .stay(Duration(hours: 1))
        .collect();

    await tripWrapper.add(points.map((e) => e.toPosition()));
    WrapperResult? result = (await tripWrapper.get());
    expect(result.confidence, greaterThan(0.9));
    expect(result.result, isNull);
  });
}
