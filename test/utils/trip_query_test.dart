import 'package:flutter_test/flutter_test.dart';
import 'package:trekko_backend/controller/trekko.dart';
import 'package:trekko_backend/controller/utils/trip_query.dart';

import '../trekko_test_utils.dart';

void main() {
  late Trekko trekko;
  setUp(() async {
    trekko = await TrekkoTestUtils.initTrekko();
  });

  test('Create trip in today and check if exists with trip query', () async {
    await trekko.saveTrip(TrekkoTestUtils.default_trip);
    DateTime start = TrekkoTestUtils.default_trip.calculateStartTime();
    DateTime end = TrekkoTestUtils.default_trip.calculateEndTime();

    expect(TripQuery(trekko).build().countSync(), 1);
    expect(TripQuery(trekko).andTimeBetween(start, end).build().countSync(), 1);
    expect(TripQuery(trekko).andTimeBetween(end, end).build().countSync(), 1);
    expect(
        TripQuery(trekko).andTimeBetween(start, start).build().countSync(), 1);
    end = end.add(const Duration(milliseconds: 1));
    start = start.subtract(const Duration(milliseconds: 1));
    expect(TripQuery(trekko).andTimeBetween(end, end).build().countSync(), 0);
    expect(
        TripQuery(trekko).andTimeBetween(start, start).build().countSync(), 0);
  });

  tearDown(() async {
    await TrekkoTestUtils.close(trekko);
  });
}
