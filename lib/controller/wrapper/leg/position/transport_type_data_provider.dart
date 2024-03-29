import 'package:trekko_backend/model/trip/transport_type.dart';
import 'package:fling_units/fling_units.dart';

abstract class TransportTypeDataProvider {

  Future<DerivedMeasurement<Measurement<Distance>, Measurement<Time>>>
      getAverageSpeed();

  TransportType getTransportType();
}
