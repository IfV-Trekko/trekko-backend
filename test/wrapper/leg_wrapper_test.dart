import 'package:trekko_backend/controller/utils/trip_builder.dart';
import 'package:trekko_backend/controller/wrapper/analyzer/leg/analyzing_leg_wrapper.dart';
import 'package:trekko_backend/controller/wrapper/analyzer/leg/leg_wrapper.dart';
import 'package:trekko_backend/controller/wrapper/wrapper_result.dart';
import 'package:trekko_backend/model/trip/leg.dart';
import 'package:trekko_backend/model/trip/tracked_point.dart';
import 'package:trekko_backend/model/trip/transport_type.dart';
import 'package:fling_units/fling_units.dart';
import 'package:test/test.dart';

void main() {
  late LegWrapper legWrapper;
  setUp(() async {
    legWrapper = AnalyzingLegWrapper([]);
  });

  test("Analyze walk to shop", () async {
    List<TrackedPoint> walkToShop = TripBuilder()
        // stay for 1h
        .stay(Duration(hours: 1))
        // walk 500m
        .move(true, Duration(minutes: 10), 500.meters)
        // stay for 5min
        .stay(Duration(hours: 1))
        .collect();

    await legWrapper.add(walkToShop.map((e) => e.toPosition()));
    WrapperResult result = await legWrapper.get();
    expect(result.confidence, greaterThan(0.95));

    Leg wrapped = result.result;
    expect(wrapped.calculateDistance().as(meters), inInclusiveRange(495, 505));
    expect(wrapped.calculateDuration().inMinutes, inInclusiveRange(9, 10));
    expect(wrapped.calculateSpeed().as(kilo.meters, hours),
        inInclusiveRange(2, 4));
    expect(wrapped.transportType, equals(TransportType.by_foot));
  });

  test("Staying at the same location: no leg", () async {
    List<TrackedPoint> points = TripBuilder()
        // stay for 1h
        .stay(Duration(hours: 1))
        // stay for 1h
        .stay(Duration(hours: 1))
        // stay for 1h
        .stay(Duration(hours: 1))
        .collect();
    await legWrapper.add(points.map((e) => e.toPosition()));
    WrapperResult result = await legWrapper.get();
    expect(result.confidence, greaterThan(0.9));
    expect(result.result, isNull);
  });

  test("Staying approx. at the same location: no leg", () async {
    List<TrackedPoint> points = TripBuilder()
        .stay(Duration(hours: 1))
        .move_r(Duration(minutes: 1), 49.meters)
        .stay(Duration(hours: 1))
        .collect();
    await legWrapper.add(points.map((e) => e.toPosition()));
    WrapperResult result = await legWrapper.get();
    expect(result.confidence, greaterThan(0.6));
    expect(result.result, isNull);
  });

  test("Moving wildly in start and end center, only one leg", () async {
    List<TrackedPoint> points = TripBuilder()
        .stay(Duration(hours: 1))
        .move(true, Duration(minutes: 1), 49.meters)
        .stay(Duration(minutes: 3))
        .move(false, Duration(minutes: 1), 49.meters)
        .stay(Duration(hours: 1))
        .move(true, Duration(minutes: 10), 500.meters)
        .move(false, Duration(seconds: 50), 30.meters)
        .move(true, Duration(seconds: 50), 30.meters)
        .stay(Duration(seconds: 20))
        .collect();

    await legWrapper.add(points.map((e) => e.toPosition()));
    WrapperResult result = await legWrapper.get();
    expect(result.confidence, greaterThan(0.95));

    Leg wrapped = result.result;
    expect(wrapped.calculateDistance().as(meters), inInclusiveRange(485, 501));
    expect(wrapped.calculateDuration().inMinutes, inInclusiveRange(9, 10));
    expect(wrapped.calculateSpeed().as(kilo.meters, hours),
        inInclusiveRange(2, 4));
    expect(wrapped.transportType, equals(TransportType.by_foot));
  });

  test("Moving wildly in start and end center, only one leg", () async {
    List<TrackedPoint> points = TripBuilder()
        .stay(Duration(hours: 1))
        .move(true, Duration(minutes: 1), 49.meters)
        .stay(Duration(minutes: 3))
        .move(false, Duration(minutes: 1), 49.meters)
        .stay(Duration(hours: 1))
        .move(true, Duration(minutes: 10), 500.meters)
        .stay(Duration(seconds: 115))
        .collect();

    await legWrapper.add(points.map((e) => e.toPosition()));
    WrapperResult result = await legWrapper.get();
    expect(result.confidence, greaterThan(0.95));

    Leg wrapped = result.result;
    expect(wrapped.calculateDistance().as(meters), inInclusiveRange(497, 502));
    expect(wrapped.calculateDuration().inMinutes, inInclusiveRange(9, 10));
    expect(wrapped.calculateSpeed().as(kilo.meters, hours),
        inInclusiveRange(2, 4));
    expect(wrapped.transportType, equals(TransportType.by_foot));
  });
}
