import 'package:trekko_backend/controller/trekko.dart';
import 'package:trekko_backend/model/trip/leg.dart';
import 'package:trekko_backend/model/trip/tracked_point.dart';
import 'package:trekko_backend/model/trip/transport_type.dart';
import 'package:trekko_backend/model/trip/trip.dart';
import 'package:fling_units/fling_units.dart';
import 'package:isar/isar.dart';
import 'package:test/test.dart';

import 'trekko_build_utils.dart';

const String password = "1aA!hklj32r4hkjl324r";
const String email = "trip_test@profile_test.com";

Trip trip1 = Trip.withData([
      Leg.withData(TransportType.bicycle, [
        TrackedPoint.withData(0, 0, 15, DateTime.now()),
        TrackedPoint.withData(0, 1, 15, DateTime.now().add(Duration(hours: 1))),
        TrackedPoint.withData(0, 2, 15, DateTime.now().add(Duration(hours: 2))),
        TrackedPoint.withData(0, 3, 15, DateTime.now().add(Duration(hours: 3))),
      ]),
    ]);
Trip trip2 = Trip.withData([
      Leg.withData(TransportType.bicycle, [
        TrackedPoint.withData(0, 0, 15, DateTime.now()),
        TrackedPoint.withData(0, 1, 15, DateTime.now().add(Duration(hours: 2))),
        TrackedPoint.withData(0, 2, 15, DateTime.now().add(Duration(hours: 4))),
        TrackedPoint.withData(0, 3, 15, DateTime.now().add(Duration(hours: 6))),
      ]),
    ]);

void main() {
  late Trekko trekko;
  late Trip trip1Read;
  late Trip trip2Read;
  setUpAll(() async {
    trekko = await TrekkoBuildUtils().loginOrRegister(email, password);
    int trip1Id = await trekko.saveTrip(trip1);
    trip1Read =
        (await trekko.getTripQuery().filter().idEqualTo(trip1Id).findFirst())!;
    int trip2Id = await trekko.saveTrip(trip2);
    trip2Read =
        (await trekko.getTripQuery().filter().idEqualTo(trip2Id).findFirst())!;
    await trekko.saveTrip(trip2);
  });

  test("Trip data correct", () async {
    expect(trip1Read.getStartTime(), equals(trip1.getStartTime()));
    expect(trip1Read.getEndTime(), equals(trip1.getEndTime()));
    expect(trip1Read.getDistance(), equals(trip1.getDistance()));
    expect(trip1Read.calculateDuration(), equals(trip1.calculateDuration()));
    expect(trip1Read.calculateSpeed(), equals(trip1.calculateSpeed()));
    expect(trip1Read.getTransportTypes(), equals(trip1.getTransportTypes()));

    expect(trip2Read.getStartTime(), equals(trip2.getStartTime()));
    expect(trip2Read.getEndTime(), equals(trip2.getEndTime()));
    expect(trip2Read.getDistance(), equals(trip2.getDistance()));
    expect(trip2Read.calculateDuration(), equals(trip2.calculateDuration()));
    expect(trip2Read.calculateSpeed(), equals(trip2.calculateSpeed()));
    expect(trip2Read.getTransportTypes(), equals(trip2.getTransportTypes()));
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

  test("Reset trip, save and read out again", () async {
    trip1Read.setDistance(2.5.kilo.meters);
    await trekko.saveTrip(trip1Read);
    trip1Read = (await trekko.getTripQuery().filter().idEqualTo(trip1Read.id).findFirst())!;
    expect(trip1Read.getDistance(), equals(2.5.kilo.meters));

    trip1Read.reset();
    await trekko.saveTrip(trip1Read);
    trip1Read = (await trekko.getTripQuery().filter().idEqualTo(trip1Read.id).findFirst())!;
    expect(trip1Read.getStartTime(), equals(trip1.getStartTime()));
    expect(trip1Read.getEndTime(), equals(trip1.getEndTime()));
    expect(trip1Read.getDistance(), equals(trip1.getDistance()));
    expect(trip1Read.calculateDuration(), equals(trip1.calculateDuration()));
    expect(trip1Read.calculateSpeed(), equals(trip1.calculateSpeed()));
    expect(trip1Read.getTransportTypes(), equals(trip1.getTransportTypes()));
  });

  tearDownAll(() async {
    await TrekkoBuildUtils().close(trekko);
  });
}
