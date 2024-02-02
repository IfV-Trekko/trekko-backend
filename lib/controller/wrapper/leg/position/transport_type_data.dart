import 'package:app_backend/controller/wrapper/leg/position/transport_type_data_provider.dart';
import 'package:app_backend/model/trip/transport_type.dart';
import 'package:fling_units/fling_units.dart';

enum TransportTypeData implements TransportTypeDataProvider {
  by_foot(4, 1, TransportType.by_foot),
  bicycle(15, 10, TransportType.bicycle),
  car(35, 50, TransportType.car),
  // publicTransport(300, 30, TransportType.publicTransport),
  // ship(50, 20, TransportType.ship),
  plane(1000, 500, TransportType.plane);

  final double maximumSpeed;
  final double averageSpeed;
  final TransportType transportType;

  const TransportTypeData(
      this.maximumSpeed, this.averageSpeed, this.transportType);

  @override
  Future<DerivedMeasurement<Measurement<Distance>, Measurement<Time>>>
      getMaximumSpeed() {
    return Future.value(maximumSpeed.kilo.meters.per(1.hours));
  }

  @override
  Future<DerivedMeasurement<Measurement<Distance>, Measurement<Time>>>
      getAverageSpeed() {
    return Future.value(averageSpeed.kilo.meters.per(1.hours));
  }

  @override
  TransportType getTransportType() {
    return transportType;
  }
}
