import 'package:trekko_backend/controller/utils/trip_builder.dart';
import 'package:fling_units/fling_units.dart';
import 'package:test/test.dart';
import 'package:trekko_backend/model/tracking/position.dart';

void main() {
  setUp(() async {});

  test("Check if tripbuilder trips are in right order date wise", () async {
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

    int newestTime = 0;
    for (Position position in walkToShopAndBack) {
      if (newestTime > position.timestamp.millisecondsSinceEpoch) {
        fail(
            "Newest time is not in right order, expected: $newestTime, got: ${position.timestamp.toString()}");
      }
      newestTime = position.timestamp.millisecondsSinceEpoch;
    }
  });
}
