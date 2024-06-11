import 'package:trekko_backend/controller/wrapper/analyzer/leg/analyzing_leg_wrapper.dart';
import 'package:trekko_backend/controller/wrapper/analyzer/leg/leg_wrapper.dart';
import 'package:trekko_backend/controller/wrapper/wrapper_result.dart';
import 'package:trekko_backend/model/tracking/raw_phone_data.dart';
import 'package:trekko_backend/model/trip/leg.dart';
import 'package:trekko_backend/model/trip/transport_type.dart';
import 'package:fling_units/fling_units.dart';
import 'package:test/test.dart';

import '../utils/data_builder.dart';
import '../utils/tracking_test_util.dart';

void main() {
  late LegWrapper legWrapper;
  setUp(() async {
    legWrapper = AnalyzingLegWrapper([]);
  });

  test("Analyze walk to shop", () async {
    await legWrapper.add(walkToShop);
    WrapperResult result = await legWrapper.get();
    expect(result.confidence, greaterThan(0.95));

    Leg wrapped = result.result;
    expect(wrapped.calculateDistance().as(meters), inInclusiveRange(495, 505));
    expect(wrapped.calculateDuration().inMinutes, inInclusiveRange(5, 6));
    expect(wrapped.calculateSpeed().as(kilo.meters, hours),
        inInclusiveRange(4, 6));
    expect(wrapped.transportType, equals(TransportType.by_foot));
  });

  test("Staying at the same location: no leg", () async {
    List<RawPhoneData> points = DataBuilder()
        // stay for 1h
        .stay(1.hours)
        // stay for 1h
        .stay(1.hours)
        // stay for 1h
        .stay(1.hours)
        .collect();
    await legWrapper.add(points);
    WrapperResult result = await legWrapper.get();
    expect(result.confidence, greaterThan(0.9));
    expect(result.result, isNull);
  });

  test("Staying approx. at the same location: no leg", () async {
    List<RawPhoneData> points =
        DataBuilder().stay(1.hours).walk(49.meters).stay(1.hours).collect();
    await legWrapper.add(points);
    WrapperResult result = await legWrapper.get();
    expect(result.confidence, greaterThan(0.6));
    expect(result.result, isNull);
  });

  test("Moving wildly in start and end center, only one leg", () async {
    List<RawPhoneData> points = DataBuilder()
        .stay(1.hours)
        .walk(49.meters)
        .stay(3.minutes)
        .walk(forward: false, 49.meters)
        .stay(1.hours)
        .walk(500.meters)
        .walk(forward: false, 30.meters)
        .walk(30.meters)
        .stay(20.seconds)
        .collect();

    await legWrapper.add(points);
    WrapperResult result = await legWrapper.get();
    expect(result.confidence, greaterThan(0.95));

    Leg wrapped = result.result;
    expect(wrapped.calculateDistance().as(meters), inInclusiveRange(560, 600));
    expect(wrapped.calculateDuration().inMinutes, inInclusiveRange(7, 8));
    expect(wrapped.calculateSpeed().as(kilo.meters, hours),
        inInclusiveRange(5, 6));
    expect(wrapped.transportType, equals(TransportType.by_foot));
  });

  test("Moving wildly in start and end center, only one leg", () async {
    List<RawPhoneData> points = DataBuilder()
        .stay(1.hours)
        .walk(49.meters)
        .stay(3.minutes)
        .walk(forward: false, 49.meters)
        .stay(1.hours)
        .walk(500.meters)
        .stay(115.seconds)
        .collect();

    await legWrapper.add(points);
    WrapperResult result = await legWrapper.get();
    expect(result.confidence, greaterThan(0.95));

    Leg wrapped = result.result;
    expect(wrapped.calculateDistance().as(meters), inInclusiveRange(497, 502));
    expect(wrapped.calculateDuration().inMinutes, inInclusiveRange(5, 6));
    expect(wrapped.calculateSpeed().as(kilo.meters, hours),
        inInclusiveRange(5, 6));
    expect(wrapped.transportType, equals(TransportType.by_foot));
  });
}
