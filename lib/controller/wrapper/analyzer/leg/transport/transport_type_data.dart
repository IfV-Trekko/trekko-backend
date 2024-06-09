import 'package:flutter_activity_recognition/models/activity_type.dart';
import 'package:trekko_backend/controller/wrapper/analyzer/leg/transport/transport_type_data_provider.dart';
import 'package:trekko_backend/model/trip/transport_type.dart';
import 'package:fling_units/fling_units.dart';

enum TransportTypeData implements TransportTypeDataProvider {
  stationary(
      transportType: null,
      activityType: ActivityType.STILL,
      maximumSpeed: 0,
      averageSpeed: 0,
      maximumHoldTimeSeconds: 5),
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
      activityType: null,
      maximumSpeed: 200,
      averageSpeed: 45,
      maximumHoldTimeSeconds: 60),
  publicTransport(
      transportType: TransportType.publicTransport,
      activityType: null,
      maximumSpeed: 300,
      averageSpeed: 30,
      maximumHoldTimeSeconds: 120),
  plane(
      transportType: TransportType.plane,
      activityType: null,
      maximumSpeed: 1000,
      averageSpeed: 800,
      maximumHoldTimeSeconds: 60 * 10);

  final TransportType? transportType;
  final ActivityType? activityType;
  final double maximumSpeed;
  final double averageSpeed;
  final double maximumHoldTimeSeconds;

  const TransportTypeData({
    required this.transportType,
    required this.activityType,
    required this.maximumSpeed,
    required this.averageSpeed,
    required this.maximumHoldTimeSeconds,
  });

  @override
  Future<DerivedMeasurement<Measurement<Distance>, Measurement<Time>>>
      getAverageSpeed() {
    return Future.value(averageSpeed.kilo.meters.per(1.hours));
  }

  @override
  TransportType? getTransportType() {
    return transportType;
  }

  static TransportTypeData? fromActivityType(ActivityType activityType) {
    return TransportTypeData.values.cast<TransportTypeData?>().firstWhere(
        (element) => element!.activityType == activityType,
        orElse: () => null);
  }
}
