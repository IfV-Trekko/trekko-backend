import 'package:trekko_backend/controller/utils/position_utils.dart';
import 'package:fling_units/fling_units.dart';
import 'package:test/test.dart';
import 'package:trekko_backend/model/tracking/position.dart';
import 'package:trekko_backend/model/tracking/raw_phone_data.dart';

import 'data_builder.dart';

void main() {
  setUp(() async {});

  test("Check if tripbuilder trips are in right order date wise", () async {
    List<RawPhoneData> walkToShopAndBack = DataBuilder()
        // stay for 1h
        .stay(1.hours)
        // walk 500m
        .walk(500.meters)
        // stay for 5min
        .stay(5.minutes)
        // walk 500m back
        .walk(forward: false, 500.meters)
        // stay for 1h
        .stay(1.hours)
        .collect()
        .toList();

    int newestTime = 0;
    for (RawPhoneData data in walkToShopAndBack) {
      if (newestTime > data.getTimestamp().millisecondsSinceEpoch) {
        fail(
            "Newest time is not in right order, expected: $newestTime, got: ${data.getTimestamp().toString()}");
      }
      newestTime = data.getTimestamp().millisecondsSinceEpoch;
    }
  });

  test("Check if tripbuilder trips are precise", () async {
    List<RawPhoneData> walkToShopAndBack = DataBuilder()
        // stay for 1h
        .stay(1.hours)
        // walk 500m
        .walk(500.meters)
        // stay for 5min
        .stay(5.minutes)
        // walk 500m back
        .walk(forward: false, 500.meters)
        // stay for 1h
        .stay(1.hours)
        .collect()
        .toList();

    DateTime start = walkToShopAndBack.first.getTimestamp();
    DateTime end = walkToShopAndBack.last.getTimestamp();
    expect(end.difference(start).inMinutes, inExclusiveRange(130, 140));

    double distance = PositionUtils.distanceBetweenPoints(
        walkToShopAndBack.where((e) => e is Position).cast());
    expect(distance, inExclusiveRange(998, 1002));
  });

  test("Check distance of trip builder", () {
    List<RawPhoneData> shortWalk = DataBuilder()
        .stay(1.hours)
        .walk(49.meters)
        .stay(1.hours)
        .collect()
        .toList();

    double distance = PositionUtils.distanceBetweenPoints(
        shortWalk.where((e) => e is Position).cast());
    expect(distance, inInclusiveRange(48, 50));

    double maxDistance =
        PositionUtils.maxDistance(shortWalk.where((e) => e is Position).cast());

    expect(maxDistance, inInclusiveRange(48, 50));
  });
}
