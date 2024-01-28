import 'package:app_backend/controller/wrapper/leg/analyzing_leg_wrapper.dart';
import 'package:app_backend/controller/wrapper/leg/leg_wrapper.dart';
import 'package:app_backend/model/trip/leg.dart';
import 'package:app_backend/model/trip/tracked_point.dart';
import 'package:app_backend/model/trip/transport_type.dart';
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
      Duration(hours: 1)),
];

void main() {
  late LegWrapper legWrapper;
  setUpAll(() async {
    legWrapper = AnalyzingLegWrapper();
  });

  test("Analyze walk to shop", () async {
    for (TrackedPoint point in walk_to_shop) {
      await legWrapper.add(point.toPosition());
    }
    double probability = await legWrapper.calculateEndProbability();
    expect(probability, greaterThan(0.9));

    Leg wrapped = await legWrapper.get();
    expect(wrapped.getDistance().as(kilo.meters).round(), equals(1));
    expect(wrapped.getDuration().inMinutes, equals(10));
    expect(wrapped.getSpeed().as(kilo.meters, hours).round(), equals(6));
    expect(wrapped.transportType, equals(TransportType.by_foot));
  });
}