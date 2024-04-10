import 'package:trekko_backend/controller/utils/trip_builder.dart';
import 'package:trekko_backend/model/position.dart';
import 'package:trekko_backend/model/trip/transport_type.dart';
import 'package:trekko_backend/model/trip/trip.dart';
import 'package:fling_units/fling_units.dart';
import 'package:test/test.dart';

import '../trekko_test_utils.dart';
import 'tracking_test_util.dart';

List<Position> composeBuilder(
    TripBuilder Function(TripBuilder) mod, int times) {
  TripBuilder builder = TripBuilder();
  for (int i = 0; i < times; i++) {
    builder = mod(builder);
  }
  return builder.collect().map((e) => e.toPosition()).toList();
}

void main() {
  setUp(() async {
    await TrekkoTestUtils.init();
    await TrekkoTestUtils.clear();
  });

  test("Analyze walk to shop and back", () async {
    int compose = 1;
    List<Position> walkToShopAndBack = composeBuilder(
            (p0) => p0
            .stay(Duration(hours: 1))
        // walk 500m
            .move(true, Duration(minutes: 10), 500.meters)
        // stay for 5min
            .stay(Duration(minutes: 5))
        // walk 500m back
            .move(false, Duration(minutes: 10), 500.meters)
        // stay for 1h
            .stay(Duration(hours: 1)),
        compose);

    await TrackingTestUtil.sendPositionsDiverse(walkToShopAndBack, (trips) {
      expect(trips.length, compose);
      for (Trip trip in trips) {
        expect(trip.legs.length, 2);
        expect(trip.legs.first.transportType, TransportType.by_foot);
        expect(trip.legs.last.transportType, TransportType.by_foot);
      }
    });
  });

  test("Analyze walk to shop and back, multiple", () async {
    int compose = 4;
    List<Position> walkToShopAndBack = composeBuilder(
        (p0) => p0
            .stay(Duration(hours: 1))
            // walk 500m
            .move(true, Duration(minutes: 10), 500.meters)
            // stay for 5min
            .stay(Duration(minutes: 5))
            // walk 500m back
            .move(false, Duration(minutes: 10), 500.meters)
            // stay for 1h
            .stay(Duration(hours: 1)),
        4);

    await TrackingTestUtil.sendPositionsDiverse(walkToShopAndBack, (trips) {
      expect(trips.length, compose);
      for (Trip trip in trips) {
        expect(trip.legs.length, 2);
        expect(trip.legs.first.transportType, TransportType.by_foot);
        expect(trip.legs.last.transportType, TransportType.by_foot);
      }
    });
  });

  test("Analyze walk to shop and back and only stay for 90 sec", () async {
    List<Position> walkToShopAndBack = TripBuilder()
        // stay for 1h
        .stay(Duration(hours: 1))
        // walk 500m
        .move(true, Duration(minutes: 10), 500.meters)
        // stay for 1min
        .stay(Duration(seconds: 90))
        // walk 500m back
        .move(false, Duration(minutes: 10), 500.meters)
        // stay for 1h
        .stay(Duration(minutes: 20))
        .collect()
        .map((e) => e.toPosition())
        .toList();

    await TrackingTestUtil.sendPositionsDiverse(walkToShopAndBack, (trips) {
      expect(trips.length, 0);
    });
  });

  test("Analyze walk to shop and back and only stay 15 min at the end",
      () async {
    List<Position> walkToShopAndBack = TripBuilder()
        // stay for 1h
        .stay(Duration(hours: 1))
        // walk 500m
        .move(true, Duration(minutes: 10), 500.meters)
        // stay for 2min
        .stay(Duration(minutes: 2))
        // walk 500m back
        .move(false, Duration(minutes: 10), 500.meters)
        // stay for 15m
        .stay(Duration(minutes: 15))
        .collect()
        .map((e) => e.toPosition())
        .toList();

    await TrackingTestUtil.sendPositionsDiverse(walkToShopAndBack, (trips) {
      expect(trips.length, 0);
    });
  });
}
