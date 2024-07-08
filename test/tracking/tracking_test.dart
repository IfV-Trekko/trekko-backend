import 'package:trekko_backend/model/tracking/raw_phone_data.dart';
import 'package:trekko_backend/model/trip/leg.dart';
import 'package:trekko_backend/model/trip/transport_type.dart';
import 'package:trekko_backend/model/trip/trip.dart';
import 'package:fling_units/fling_units.dart';
import 'package:test/test.dart';

import '../trekko_test_utils.dart';
import '../utils/data_builder.dart';
import '../utils/tracking_test_util.dart';

void main() {
  List<RawPhoneData> composeBuilder(
      DataBuilder Function(DataBuilder) mod, int times) {
    DataBuilder builder = DataBuilder();
    for (int i = 0; i < times; i++) {
      builder = mod(builder);
    }
    return builder.collect();
  }

  setUp(() async {
    await TrekkoTestUtils.init();
    await TrekkoTestUtils.clear();
  });

  test("Analyze walk to shop and back", () async {
    await TrackingTestUtil.sendDataDiverse(walkToShopAndBack, (trips) {
      expect(trips.length, 1);
      for (Trip trip in trips) {
        expect(trip.legs.length, 2);
        expect(trip.legs.first.transportType, TransportType.by_foot);
        expect(trip.legs.last.transportType, TransportType.by_foot);
      }
    });
  });

  test("Analyze walk to shop and back, multiple", () async {
    int compose = 4;
    List<RawPhoneData> walkToShopAndBack = composeBuilder(
        (p0) => p0
            .stay(1.hours)
            .walk(500.meters)
            .stay(5.minutes)
            .walk(forward: false, 500.meters)
            .stay(1.hours),
        4);

    await TrackingTestUtil.sendDataDiverse(walkToShopAndBack, (trips) {
      expect(trips.length, compose);
      for (Trip trip in trips) {
        expect(trip.legs.length, 2);
        expect(trip.legs.first.transportType, TransportType.by_foot);
        expect(trip.legs.last.transportType, TransportType.by_foot);
      }
    });
  });

  test("Analyze walk to shop and back and only stay for 90 sec", () async {
    List<RawPhoneData> walkToShopAndBack = DataBuilder()
        // stay for 1h
        .stay(1.hours)
        // walk 500m
        .walk(500.meters)
        // stay for 1min
        .stay(90.seconds)
        // walk 500m back
        .walk(forward: false, 500.meters)
        // stay for 1h
        .stay(20.minutes)
        .collect();

    await TrackingTestUtil.sendDataDiverse(walkToShopAndBack, (trips) {
      expect(trips.length, 0);
    });
  });

  test("Analyze walk to shop and back and only stay 15 min at the end",
      () async {
    List<RawPhoneData> walkToShopAndBack = DataBuilder()
        .stay(1.hours)
        .walk(500.meters)
        .stay(2.minutes)
        .walk(forward: false, 500.meters)
        .stay(15.minutes)
        .collect();

    await TrackingTestUtil.sendDataDiverse(walkToShopAndBack, (trips) {
      expect(trips.length, 0);
    });
  });

  test("Analyze walk with some wild movements", () async {
    List<RawPhoneData> points = DataBuilder()
        .stay(1.hours)
        .walk(24.meters)
        .walk(forward: false, 24.meters)
        .stay(1.hours)
        .walk(500.meters)
        .walk(30.meters)
        .walk(forward: false, 32.meters)
        .stay(27.minutes)
        .collect();

    await TrackingTestUtil.sendDataDiverse(points, (trips) {
      expect(trips.length, 1);
      expect(trips.first.legs.length, 1);
      Leg wrapped = trips.first.legs.first;
      print(wrapped.calculateStartTime());
      print(wrapped.calculateEndTime());
      expect(
          wrapped.calculateDistance().as(meters), inInclusiveRange(560, 565));
      expect(wrapped.calculateDuration().inMinutes, inInclusiveRange(6, 7));
      expect(wrapped.calculateSpeed().as(kilo.meters, hours),
          inInclusiveRange(4, 6));
      expect(wrapped.transportType, equals(TransportType.by_foot));
    });
  });

  test("Analyze walk with some wild movements, 2 trips", () async {
    List<RawPhoneData> points = DataBuilder()
        .stay(1.hours)
        .walk(50.meters)
        .walk(forward: false, 50.meters)
        .stay(1.hours)
        .walk(500.meters)
        .walk(30.meters)
        .walk(forward: false, 32.meters)
        .stay(27.minutes)
        .collect();

    await TrackingTestUtil.sendDataDiverse(points, (trips) {
      expect(trips.length, 2);
    });
  });
}
