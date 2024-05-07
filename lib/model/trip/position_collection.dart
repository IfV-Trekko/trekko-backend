import 'package:fling_units/fling_units.dart';
import 'package:trekko_backend/model/trip/leg.dart';
import 'package:trekko_backend/model/trip/tracked_point.dart';
import 'package:trekko_backend/model/trip/transport_type.dart';

abstract class PositionCollection {

  /// Returns the tracked points of the collection
  List<Leg> getLegs();

  /// Returns the start time of the collection
  DateTime calculateStartTime();

  /// Returns the end time of the collection
  DateTime calculateEndTime();

  /// Returns the average speed of the collection
  DerivedMeasurement<Measurement<Distance>, Measurement<Time>> calculateSpeed() {
    return ((this.calculateDistance().as(meters) /
        this.calculateDuration().inSeconds.toDouble()) *
        3.6)
        .kilo
        .meters
        .per(1.hours);
  }

  /// Returns the distance of the collection
  Distance calculateDistance();

  /// Returns the duration of the collection
  Duration calculateDuration() {
    return this.calculateEndTime().difference(this.calculateStartTime());
  }

  TrackedPoint calculateStartPoint() {
    return this.getLegs().first.trackedPoints.first;
  }

  TrackedPoint calculateEndPoint() {
    return this.getLegs().last.trackedPoints.last;
  }

  /// Returns the transport types of the collection
  List<TransportType> calculateTransportTypes();

  TransportType calculateMostUsedType();

  bool deepEquals(PositionCollection other);

}