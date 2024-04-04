import 'package:flutter_test/flutter_test.dart';
import 'package:trekko_backend/controller/trekko.dart';
import 'package:trekko_backend/controller/utils/trip_query.dart';

import '../trekko_test_utils.dart';

void main() {
  late Trekko trekko;
  setUp(() async {
    trekko = await TrekkoTestUtils.initTrekko();
  });

  test('Create trip in today and check if exists with trip query', () {
    trekko.saveTrip(TrekkoTestUtils.default_trip);

    DateTime now = TrekkoTestUtils.default_trip.startTime;
    DateTime start = DateTime(now.year, now.month, now.day);
    DateTime end = DateTime(now.year, now.month, now.day, 23, 59, 59);

    expect(true,
        TripQuery(trekko).andTimeBetween(start, end).build().isNotEmptySync());
  });

  tearDown(() async {
    await TrekkoTestUtils.close(trekko);
  });
}
