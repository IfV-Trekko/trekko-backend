import 'package:app_backend/controller/request/bodies/request/trips_request.dart';
import 'package:app_backend/controller/request/bodies/server_trip.dart';
import 'package:app_backend/model/trip/leg.dart';
import 'package:app_backend/model/trip/tracked_point.dart';
import 'package:app_backend/model/trip/transport_type.dart';
import 'package:app_backend/model/trip/trip.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('TripsRequest Tests', () {
    test('ServerTrip.fromTrip creates correct instance from Trip', () {
      final trackedPoint1 = TrackedPoint.withData(
        52.5200,
        13.4050,
        10.0,
        DateTime(2021, 1, 1, 10, 0), // Beispielsdaten
      );
      final trackedPoint2 = TrackedPoint.withData(
        52.5200,
        13.4060,
        12.0,
        DateTime(2021, 1, 1, 10, 5), // 5 Minuten später
      );

      final leg = Leg.withData(TransportType.by_foot, [trackedPoint1, trackedPoint2]);

      final trip = Trip.withData([leg])
        ..startTime = DateTime(2021, 1, 1)
        ..endTime = DateTime(2021, 1, 2)
        ..distanceInMeters = 1000.0
        ..transportTypes = [TransportType.by_foot.name, TransportType.bicycle.name]
        ..comment = "Test trip"
        ..purpose = "Commuting";
      final serverTrip = ServerTrip.fromTrip(trip);

      expect(serverTrip.startTimestamp, equals(trip.getStartTime().millisecondsSinceEpoch));
      expect(serverTrip.endTimestamp, equals(trip.getEndTime().millisecondsSinceEpoch));
      expect(serverTrip.distance, equals(trip.distanceInMeters));
      expect(serverTrip.transportTypes, containsAll(['BY_FOOT', 'BICYCLE']));
      expect(serverTrip.comment, equals(trip.comment));
      expect(serverTrip.purpose, equals(trip.purpose));
    });

    test('TripsRequest toJson', () {
      final tripsRequest = TripsRequest([
        ServerTrip(
          'uid123',
          1609459200000,
          1609545600000,
          100.0,
          ['Walking', 'Biking'],
          'Work',
          'No comment',
        )
      ]);

      expect(tripsRequest.toJson(), [
        {
          'uid': 'uid123',
          'startTimestamp': 1609459200000,
          'endTimestamp': 1609545600000,
          'distance': 100.0,
          'transportTypes': ['Walking', 'Biking'],
          'purpose': 'Work',
          'comment': 'No comment',
        }
      ]);
    });

    test('TripsRequest fromJson', () {
      final json = [
        {
          'uid': 'uid123',
          'startTimestamp': 1609459200000,
          'endTimestamp': 1609545600000,
          'distance': 100.0,
          'transportTypes': ['Walking', 'Biking'],
          'purpose': 'Work',
          'comment': 'No comment',
        }
      ];
      final tripsRequest = TripsRequest.fromJson(json);

      expect(tripsRequest.trips.length, 1);
      final serverTrip = tripsRequest.trips.first;
      expect(serverTrip.uid, 'uid123');
      expect(serverTrip.distance, 100.0);
    });

  });
}

