import 'package:trekko_backend/controller/wrapper/analyzer/leg/position/transport_type_data_provider.dart';
import 'package:trekko_backend/model/trip/transport_type.dart';
import 'package:fling_units/fling_units.dart';

enum TransportTypeData implements TransportTypeDataProvider {
  none(null, 0, 0, 5),
  by_foot(TransportType.by_foot, 13, 5, 10),
  bicycle(TransportType.bicycle, 30, 16, 30),
  car(TransportType.car, 200, 45, 60),
  // publicTransport(300, 30, TransportType.publicTransport),
  // ship(50, 20, TransportType.ship),
  plane(TransportType.plane, 1000, 800, 60 * 10);

  final double maximumSpeed;
  final double averageSpeed;
  final double maximumHoldTimeSeconds;
  final TransportType? transportType;

  const TransportTypeData(this.transportType, this.maximumSpeed,
      this.averageSpeed, this.maximumHoldTimeSeconds);

  @override
  Future<DerivedMeasurement<Measurement<Distance>, Measurement<Time>>>
      getAverageSpeed() {
    return Future.value(averageSpeed.kilo.meters.per(1.hours));
  }

  @override
  TransportType? getTransportType() {
    return transportType;
  }
}
