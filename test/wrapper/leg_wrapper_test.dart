import 'package:app_backend/controller/wrapper/leg/analyzing_leg_wrapper.dart';
import 'package:app_backend/controller/wrapper/leg/leg_wrapper.dart';
import 'package:app_backend/model/trip/leg.dart';
import 'package:app_backend/model/trip/tracked_point.dart';
import 'package:app_backend/model/trip/transport_type.dart';
import 'package:fling_units/fling_units.dart';
import 'package:test/test.dart';

import '../trip_gen_utils.dart';

void main() {
  late LegWrapper legWrapper;
  setUp(() async {
    legWrapper = AnalyzingLegWrapper();
  });

  test("Analyze walk to shop", () async {
    List<TrackedPoint> walkToShop = [
      // stay for 1h
      ...stay(Duration(hours: 1)),
      // walk 500m
      ...move(0.5, 0.5, Duration(minutes: 10), 500.meters),
      // stay for 5min
      ...stay(Duration(hours: 1)),
    ];

    for (TrackedPoint point in walkToShop) {
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

  test("Staying at the same location: no leg", () async {
    List<TrackedPoint> points = [
      ...stay(Duration(hours: 1)),
      ...stay(Duration(hours: 1)),
      ...stay(Duration(hours: 1)),
    ];
    for (TrackedPoint point in points) {
      await legWrapper.add(point.toPosition());
    }
    double probability = await legWrapper.calculateEndProbability();
    expect(probability, lessThan(0.1));
  });
}
