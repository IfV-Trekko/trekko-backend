import 'package:app_backend/model/trip/transport_type.dart';

abstract class TransportTypeDataProvider {
  Future<double> getMaximumSpeed();

  Future<double> getAverageSpeed();

  TransportType getTransportType();
}
