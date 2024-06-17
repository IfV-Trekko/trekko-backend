import 'package:flutter_activity_recognition/models/activity_type.dart';
import 'package:trekko_backend/controller/wrapper/analyzer/leg/transport/position/patternizer.dart';
import 'package:trekko_backend/controller/wrapper/analyzer/leg/transport/position/repeating_stops_patternizer.dart';
import 'package:trekko_backend/controller/wrapper/analyzer/leg/transport/transport_type_data_provider.dart';
import 'package:trekko_backend/model/trip/transport_type.dart';
import 'package:fling_units/fling_units.dart';

enum TransportTypeData implements TransportTypeDataProvider {
  stationary(
      transportType: null,
      activityType: ActivityType.STILL,
      maximumSpeed: 0,
      averageSpeed: 0,
      maximumHoldTimeSeconds: 15),
  walking(
      transportType: TransportType.by_foot,
      activityType: ActivityType.WALKING,
      maximumSpeed: 13,
      averageSpeed: 5,
      maximumHoldTimeSeconds: 15),
  running(
      transportType: TransportType.by_foot,
      activityType: ActivityType.RUNNING,
      maximumSpeed: 16,
      averageSpeed: 8,
      maximumHoldTimeSeconds: 10),
  bicycle(
      transportType: TransportType.bicycle,
      activityType: ActivityType.ON_BICYCLE,
      maximumSpeed: 30,
      averageSpeed: 16,
      maximumHoldTimeSeconds: 30),
  car(
      transportType: TransportType.car,
      activityType: ActivityType.IN_VEHICLE,
      maximumSpeed: 200,
      averageSpeed: 45,
      maximumHoldTimeSeconds: 60 * 3),
  publicTransport(
      transportType: TransportType.publicTransport,
      activityType: ActivityType.IN_VEHICLE,
      maximumSpeed: 300,
      averageSpeed: 30,
      maximumHoldTimeSeconds: 60 * 5,
      patternizer: RepeatingStopsPatternizer()),
  plane(
      transportType: TransportType.plane,
      activityType: null,
      maximumSpeed: 1000,
      averageSpeed: 800,
      maximumHoldTimeSeconds: 60 * 5);

  final TransportType? transportType;
  final ActivityType? activityType;
  final double maximumSpeed;
  final double averageSpeed;
  final double maximumHoldTimeSeconds;
  final Patternizer? patternizer;

  const TransportTypeData({
    required this.transportType,
    required this.activityType,
    required this.maximumSpeed,
    required this.averageSpeed,
    required this.maximumHoldTimeSeconds,
    this.patternizer = null,
  });

  @override
  DerivedMeasurement<Measurement<Distance>, Measurement<Time>>
      getAverageSpeed() {
    return averageSpeed.kilo.meters.per(1.hours);
  }

  @override
  Time getMaximumStopTime() {
    return maximumHoldTimeSeconds.seconds;
  }

  @override
  Patternizer getPatternizer() {
    return patternizer != null ? patternizer! : Patternizer.static(0.5);
  }

  @override
  TransportType? getTransportType() {
    return transportType;
  }

  static Iterable<TransportTypeData> fromActivityType(
      ActivityType activityType) {
    return TransportTypeData.values
        .where((element) => element.activityType == activityType);
  }
}
