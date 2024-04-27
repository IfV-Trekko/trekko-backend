import 'package:trekko_backend/controller/trekko.dart';
import 'package:trekko_backend/model/trip/leg.dart';
import 'package:trekko_backend/model/trip/tracked_point.dart';
import 'package:trekko_backend/model/trip/transport_type.dart';
import 'package:trekko_backend/model/trip/trip.dart';
import 'package:test/test.dart';

import 'trekko_test_utils.dart';

Trip trip1 = Trip.withData([
      Leg.withData(TransportType.bicycle, [
        TrackedPoint.withData(0, 0, DateTime.now()),
        TrackedPoint.withData(0, 1, DateTime.now().add(Duration(hours: 1))),
        TrackedPoint.withData(0, 2, DateTime.now().add(Duration(hours: 2))),
        TrackedPoint.withData(0, 3, DateTime.now().add(Duration(hours: 3))),
      ]),
    ]);
Trip trip2 = Trip.withData([
      Leg.withData(TransportType.bicycle, [
        TrackedPoint.withData(0, 0, DateTime.now()),
        TrackedPoint.withData(0, 1, DateTime.now().add(Duration(hours: 2))),
        TrackedPoint.withData(0, 2, DateTime.now().add(Duration(hours: 4))),
        TrackedPoint.withData(0, 3, DateTime.now().add(Duration(hours: 6))),
      ]),
    ]);

void main() {
  late Trekko trekko;
  late Trip trip1Read;
  late Trip trip2Read;
  setUpAll(() async {
    trekko = await TrekkoTestUtils.initTrekko();
    int trip1Id = await trekko.saveTrip(trip1);
    trip1Read =
        (await trekko.getTripQuery().andId(trip1Id).collectFirst())!;
    int trip2Id = await trekko.saveTrip(trip2);
    trip2Read =
        (await trekko.getTripQuery().andId(trip2Id).collectFirst())!;
    await trekko.saveTrip(trip2);
  });

  test("Trip data correct", () async {
    expect(trip1Read.calculateStartTime(), equals(trip1.calculateStartTime()));
    expect(trip1Read.calculateEndTime(), equals(trip1.calculateEndTime()));
    expect(trip1Read.calculateDistance(), equals(trip1.calculateDistance()));
    expect(trip1Read.calculateDuration(), equals(trip1.calculateDuration()));
    expect(trip1Read.calculateSpeed(), equals(trip1.calculateSpeed()));
    expect(trip1Read.calculateTransportTypes(), equals(trip1.calculateTransportTypes()));

    expect(trip2Read.calculateStartTime(), equals(trip2.calculateStartTime()));
    expect(trip2Read.calculateEndTime(), equals(trip2.calculateEndTime()));
    expect(trip2Read.calculateDistance(), equals(trip2.calculateDistance()));
    expect(trip2Read.calculateDuration(), equals(trip2.calculateDuration()));
    expect(trip2Read.calculateSpeed(), equals(trip2.calculateSpeed()));
    expect(trip2Read.calculateTransportTypes(), equals(trip2.calculateTransportTypes()));
  });

  test("TrackedPoint data correct", () async {
    expect(trip1Read.legs[0].trackedPoints[0].latitude,
        equals(trip1.legs[0].trackedPoints[0].latitude));
    expect(trip1Read.legs[0].trackedPoints[0].longitude,
        equals(trip1.legs[0].trackedPoints[0].longitude));
    expect(trip1Read.legs[0].trackedPoints[0].latitude,
        equals(trip1.legs[0].trackedPoints[0].latitude));
    expect(trip1Read.legs[0].trackedPoints[0].timestamp,
        equals(trip1.legs[0].trackedPoints[0].timestamp));

    expect(trip2Read.legs[0].trackedPoints[0].latitude,
        equals(trip2.legs[0].trackedPoints[0].latitude));
    expect(trip2Read.legs[0].trackedPoints[0].longitude,
        equals(trip2.legs[0].trackedPoints[0].longitude));
    expect(trip2Read.legs[0].trackedPoints[0].latitude,
        equals(trip2.legs[0].trackedPoints[0].latitude));
    expect(trip2Read.legs[0].trackedPoints[0].timestamp,
        equals(trip2.legs[0].trackedPoints[0].timestamp));
  });

  tearDownAll(() async {
    await TrekkoTestUtils.close(trekko);
  });
}
