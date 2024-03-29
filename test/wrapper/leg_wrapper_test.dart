import 'package:trekko_backend/controller/utils/trip_builder.dart';
import 'package:trekko_backend/controller/wrapper/leg/analyzing_leg_wrapper.dart';
import 'package:trekko_backend/controller/wrapper/leg/leg_wrapper.dart';
import 'package:trekko_backend/model/trip/leg.dart';
import 'package:trekko_backend/model/trip/tracked_point.dart';
import 'package:trekko_backend/model/trip/transport_type.dart';
import 'package:fling_units/fling_units.dart';
import 'package:test/test.dart';

void main() {
  late LegWrapper legWrapper;
  setUp(() async {
    legWrapper = AnalyzingLegWrapper();
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

    for (TrackedPoint point in walkToShop) {
      await legWrapper.add(point.toPosition());
    }
    double probability = await legWrapper.calculateEndProbability();
    expect(probability, greaterThan(0.9));

    Leg wrapped = await legWrapper.get();
    expect(wrapped.getDistance().as(meters), inInclusiveRange(495, 505));
    expect(wrapped.getDuration().inMinutes, inInclusiveRange(9, 10));
    expect(wrapped.getSpeed().as(kilo.meters, hours), inInclusiveRange(2, 4));
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
    for (TrackedPoint point in points) {
      await legWrapper.add(point.toPosition());
    }
    double probability = await legWrapper.calculateEndProbability();
    expect(probability, lessThan(0.1));
  });
}
