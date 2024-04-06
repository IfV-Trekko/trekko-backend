import 'package:fling_units/fling_units.dart';
import 'package:trekko_backend/model/trip/leg.dart';
import 'package:trekko_backend/model/trip/transport_type.dart';

abstract class PositionCollection {

  /// Returns the tracked points of the collection
  List<Leg> getLegs();

  /// Returns the start time of the collection
  DateTime calculateStartTime();

  /// Returns the end time of the collection
  DateTime calculateEndTime();

  /// Returns the average speed of the collection
  DerivedMeasurement<Measurement<Distance>, Measurement<Time>> calculateSpeed();

  /// Returns the distance of the collection
  Distance calculateDistance();

  /// Returns the duration of the collection
  Duration calculateDuration();

  /// Returns the transport types of the collection
  List<TransportType> calculateTransportTypes();

}