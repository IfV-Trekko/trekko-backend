import 'package:app_backend/controller/wrapper/leg/position/transport_type_data_provider.dart';
import 'package:app_backend/model/trip/transport_type.dart';

enum TransportTypeData implements TransportTypeDataProvider {

  by_foot;

  @override
  Future<double> getMaximumSpeed() {
    return Future.value(0);
  }

  @override
  Future<double> getAverageSpeed() {
    return Future.value(0);
  }

  @override
  TransportType getTransportType() {
    return TransportType.by_foot;
  }
}