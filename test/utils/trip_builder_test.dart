import 'package:app_backend/controller/utils/trip_builder.dart';
import 'package:background_locator_2/location_dto.dart';
import 'package:fling_units/fling_units.dart';
import 'package:test/test.dart';

void main() {
  setUp(() async {});

  test("Check if tripbuilder trips are in right order date wise", () async {
    List<LocationDto> walkToShopAndBack =
        TripBuilder.withData(0, 0, skipStayPoints: false)
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
            .map((e) => e.toPosition().toLocationDto())
            .toList();

    double newestTime = 0;
    for (LocationDto locationDto in walkToShopAndBack) {
      if (newestTime > locationDto.time) {
        fail(
            "Newest time is not in right order, expected: $newestTime, got: ${locationDto.time}");
      }
      newestTime = locationDto.time;
    }
  });
}
