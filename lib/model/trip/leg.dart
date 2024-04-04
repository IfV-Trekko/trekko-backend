import 'package:trekko_backend/controller/utils/position_utils.dart';
import 'package:trekko_backend/model/trip/position_collection.dart';
import 'package:trekko_backend/model/trip/tracked_point.dart';
import 'package:trekko_backend/model/trip/transport_type.dart';
import 'package:fling_units/fling_units.dart';
import 'package:isar/isar.dart';

part 'leg.g.dart';

@embedded
class Leg implements PositionCollection {
  @enumerated
  TransportType transportType; // TODO: final
  List<TrackedPoint> trackedPoints;

  /// Creates a new leg
  Leg()
      : transportType = TransportType.car,
        trackedPoints = List.empty(growable: true);

  /// Creates a leg with the given data
  Leg.withData(this.transportType, this.trackedPoints) {
    if (this.trackedPoints.length < 2) {
      throw Exception("A leg must have at least two tracked points");
    }

    for (int i = 1; i < this.trackedPoints.length; i++) {
      if (this
          .trackedPoints[i]
          .timestamp
          .isBefore(this.trackedPoints[i - 1].timestamp)) {
        throw Exception("The tracked points must be in chronological order");
      }
    }
  }

  @override
  DateTime calculateStartTime() {
    return this.trackedPoints.first.timestamp;
  }

  @override
  DateTime calculateEndTime() {
    return this.trackedPoints.last.timestamp;
  }

  @override
  Duration calculateDuration() {
    return this.calculateEndTime().difference(this.calculateStartTime());
  }

  @override
  DerivedMeasurement<Measurement<Distance>, Measurement<Time>> calculateSpeed() {
    return ((this.calculateDistance().as(meters) /
                this.calculateDuration().inSeconds.toDouble()) *
            3.6)
        .kilo
        .meters
        .per(1.hours);
  }

  @override
  Distance calculateDistance() {
    double distanceInMeters = 0;
    for (int i = 1; i < trackedPoints.length; i++) {
      TrackedPoint p0 = trackedPoints[i - 1];
      TrackedPoint p1 = trackedPoints[i];
      distanceInMeters += PositionUtils.calculateDistance(
          p0.latitude, p0.longitude, p1.latitude, p1.longitude);
    }
    return distanceInMeters.meters;
  }

  @override
  List<TransportType> calculateTransportTypes() {
    return [this.transportType];
  }

  @override
  List<Leg> getLegs() {
    return [this];
  }
}
