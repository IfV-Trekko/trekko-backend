import 'package:flutter_test/flutter_test.dart';
import 'package:trekko_backend/controller/trekko.dart';

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

    expect(await trekko.getTripQuery().count(), 1);
    expect(await trekko.getTripQuery().andTimeBetween(start, end).count(), 1);
    expect(await trekko.getTripQuery().andTimeBetween(end, end).count(), 1);
    expect(await trekko.getTripQuery().andTimeBetween(start, start).count(), 1);
    end = end.add(const Duration(milliseconds: 1));
    start = start.subtract(const Duration(milliseconds: 1));
    expect(await trekko.getTripQuery().andTimeBetween(end, end).count(), 0);
    expect(await trekko.getTripQuery().andTimeBetween(start, start).count(), 0);
  });

  tearDown(() async {
    await TrekkoTestUtils.close(trekko);
  });
}
