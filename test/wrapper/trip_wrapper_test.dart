import 'package:trekko_backend/controller/wrapper/analyzer/analyzing_trip_wrapper.dart';
import 'package:trekko_backend/controller/wrapper/analyzer/trip_wrapper.dart';
import 'package:trekko_backend/controller/wrapper/wrapper_result.dart';
import 'package:trekko_backend/model/tracking/raw_phone_data.dart';
import 'package:trekko_backend/model/trip/trip.dart';
import 'package:fling_units/fling_units.dart';
import 'package:test/test.dart';

import '../trekko_test_utils.dart';
import '../utils/data_builder.dart';
import '../utils/tracking_test_util.dart';

void main() {
  late TripWrapper tripWrapper;
  setUp(() async {
    await TrekkoTestUtils.init();
    tripWrapper = AnalyzingTripWrapper([]);
  });

  test("Analyze walk to shop and back", () async {
    await tripWrapper.add(walkToShopAndBack);
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
    List<RawPhoneData> points = DataBuilder()
        // stay for 1h
        .stay(1.hours)
        // stay for 1h
        .stay(1.hours)
        // stay for 1h
        .stay(1.hours)
        .collect();

    await tripWrapper.add(points);
    WrapperResult? result = (await tripWrapper.get());
    expect(result.confidence, greaterThan(0.9));
    expect(result.result, isNull);
  });
}
