import 'package:trekko_backend/controller/trekko.dart';
import 'package:trekko_backend/controller/utils/trip_builder.dart';
import 'package:trekko_backend/model/position.dart';
import 'package:trekko_backend/model/tracking_state.dart';
import 'package:trekko_backend/model/trip/transport_type.dart';
import 'package:trekko_backend/model/trip/trip.dart';
import 'package:fling_units/fling_units.dart';
import 'package:isar/isar.dart';
import 'package:test/test.dart';

import '../trekko_test_utils.dart';
import 'tracking_test_util.dart';

void main() {
  Trekko? trekko;
  List<Position> walkToShopAndBack = TripBuilder()
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
      .collect()
      .map((e) => e.toPosition())
      .toList();

  setUp(() async {
    await TrekkoTestUtils.init();
    await TrackingTestUtil.clearCache();
  });

  test("Analyze walk to shop and back in cache", () async {
    await TrackingTestUtil.sendToCache(walkToShopAndBack);
    trekko = await TrekkoTestUtils.initTrekko();
    await trekko!.setTrackingState(TrackingState.running);
    await TrackingTestUtil.waitForFinishProcessing(trekko!);

    List<Trip> trips = await trekko!.getTripQuery().findAll();
    expect(trips.length, 1);
    Trip trip = trips.first;
    expect(trip.legs.length, 2);
    expect(trip.legs.first.transportType, TransportType.by_foot);
    expect(trip.legs.last.transportType, TransportType.by_foot);
  });

  tearDown(() async {
    if (trekko == null) return;
    await TrekkoTestUtils.close(trekko!);
  });
}
