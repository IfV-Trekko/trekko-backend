import 'package:app_backend/controller/wrapper/leg/position/transport_type_data_provider.dart';
import 'package:app_backend/model/trip/transport_type.dart';

enum TransportTypeData implements TransportTypeDataProvider {
  by_foot(5, 1, TransportType.by_foot),
  bicycle(20, 10, TransportType.bicycle),
  car(200, 50, TransportType.car),
  // publicTransport(300, 30, TransportType.publicTransport),
  // ship(50, 20, TransportType.ship),
  plane(1000, 500, TransportType.plane);

  final double maximumSpeed;
  final double averageSpeed;
  final TransportType transportType;

  const TransportTypeData(this.maximumSpeed, this.averageSpeed, this.transportType);

  @override
  Future<double> getMaximumSpeed() {
    return Future.value(maximumSpeed);
  }

  @override
  Future<double> getAverageSpeed() {
    return Future.value(averageSpeed);
  }

  @override
  TransportType getTransportType() {
    return transportType;
  }
}
