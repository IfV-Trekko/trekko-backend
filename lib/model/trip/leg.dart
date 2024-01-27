import 'package:app_backend/model/trip/tracked_point.dart';
import 'package:app_backend/model/trip/transport_type.dart';
import 'package:fling_units/fling_units.dart';
import 'package:geolocator/geolocator.dart';
import 'package:isar/isar.dart';

part 'leg.g.dart';

@embedded
class Leg {
  @enumerated
  TransportType transportType; // TODO: final
  List<TrackedPoint> trackedPoints;

  Leg()
      : transportType = TransportType.car,
        trackedPoints = List.empty(growable: true);

  Leg.withData(this.transportType, this.trackedPoints) {
    if (this.trackedPoints.length < 2) {
      throw Exception("A leg must have at least two tracked points");
    }

    for (int i = 1; i < this.trackedPoints.length; i++) {
      if (this.trackedPoints[i].timestamp.isBefore(this.trackedPoints[i - 1].timestamp)) {
        throw Exception("The tracked points must be in chronological order");
      }
    }
  }

  DateTime getStartTime() {
    return this.trackedPoints.first.timestamp;
  }

  DateTime getEndTime() {
    return this.trackedPoints.last.timestamp;
  }

  Duration getDuration() {
    return this.getEndTime().difference(this.getStartTime());
  }

  DerivedMeasurement<Measurement<Distance>, Measurement<Time>> getSpeed() {
    return this.getDistance().per(this.getDuration().inSeconds.seconds);
  }

  Distance getDistance() {
    double distanceInMeters = 0;
    for (int i = 1; i < trackedPoints.length; i++) {
      TrackedPoint p0 = trackedPoints[i - 1];
      TrackedPoint p1 = trackedPoints[i];
      distanceInMeters += Geolocator.distanceBetween(
          p0.latitude, p0.longitude, p1.latitude, p1.longitude);
    }
    return meters(distanceInMeters);
  }
}
