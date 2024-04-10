import 'package:trekko_backend/controller/trekko.dart';
import 'package:trekko_backend/controller/utils/database_utils.dart';
import 'package:trekko_backend/controller/utils/trip_builder.dart';
import 'package:trekko_backend/model/cache_object.dart';
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
    await TrekkoTestUtils.clear();
  });

  void checkTrips() async {
    List<Trip> trips = await trekko!.getTripQuery().findAll();
    expect(trips.length, 1);
    Trip trip = trips.first;
    expect(trip.legs.length, 2);
    expect(trip.legs.first.transportType, TransportType.by_foot);
    expect(trip.legs.last.transportType, TransportType.by_foot);
  }

  Future<void> checkCacheLength(int length) async {
    Isar cache = (await Databases.cache.getInstance(openIfNone: true))!;
    expect(await cache.cacheObjects.count(), length);
  }

  test("Send locations to cache and wait for them to be read out", () async {
    await TrackingTestUtil.sendToCache(walkToShopAndBack);
    trekko = await TrekkoTestUtils.initTrekko(signOut: false);
    await trekko!.setTrackingState(TrackingState.running);
    await TrackingTestUtil.waitForFinishProcessing(trekko!);
    checkTrips();
  });

  test("Put locations into cache and live location", () async {
    await TrackingTestUtil.sendToCache(
        walkToShopAndBack.sublist(0, walkToShopAndBack.length ~/ 2));
    trekko = await TrekkoTestUtils.initTrekko(signOut: false);
    await trekko!.setTrackingState(TrackingState.running);

    await TrackingTestUtil.sendPositions(
        trekko!, walkToShopAndBack.sublist(walkToShopAndBack.length ~/ 2));
    await TrackingTestUtil.waitForFinishProcessing(trekko!);
    checkTrips();
  });

  test("Test if location will be processed after reinit 2x", () async {
    await TrackingTestUtil.sendToCache(
        walkToShopAndBack.sublist(0, walkToShopAndBack.length ~/ 2));
    trekko = await TrekkoTestUtils.initTrekko(signOut: false);
    await trekko!.setTrackingState(TrackingState.running);
    await trekko!.terminate();

    await checkCacheLength(walkToShopAndBack.length ~/ 2);
    await TrackingTestUtil.sendToCache(
        walkToShopAndBack.sublist(walkToShopAndBack.length ~/ 2));

    await checkCacheLength(walkToShopAndBack.length);
    trekko = await TrekkoTestUtils.initTrekko(signOut: false);
    await trekko!.setTrackingState(TrackingState.running);
    await TrackingTestUtil.waitForFinishProcessing(trekko!);
    checkTrips();
  });

  test("Test if location will be processed (2x reinit) and send other half",
      () async {
    await TrackingTestUtil.sendToCache(
        walkToShopAndBack.sublist(0, walkToShopAndBack.length ~/ 2));
    trekko = await TrekkoTestUtils.initTrekko(signOut: false);
    await trekko!.setTrackingState(TrackingState.running);
    await trekko!.terminate();

    await checkCacheLength(walkToShopAndBack.length ~/ 2);
    trekko = await TrekkoTestUtils.initTrekko(signOut: false);
    await trekko!.setTrackingState(TrackingState.running);

    await TrackingTestUtil.sendPositions(
        trekko!, walkToShopAndBack.sublist(walkToShopAndBack.length ~/ 2));
    await TrackingTestUtil.waitForFinishProcessing(trekko!);
    checkTrips();
  });

  tearDown(() async {
    if (trekko == null) return;
    await TrekkoTestUtils.close(trekko!);
  });
}
