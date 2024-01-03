import 'package:app_backend/controller/wrapper/leg/position/transport_type_data_provider.dart';
import 'package:app_backend/controller/wrapper/leg/position/transport_type_evaluator.dart';
import 'package:app_backend/model/trip/transport_type.dart';
import 'package:geolocator/geolocator.dart';

class WeightedTransportTypeEvaluator implements TransportTypeEvaluator {
  final TransportTypeDataProvider dataProvider;

  WeightedTransportTypeEvaluator(this.dataProvider);

  @override
  Future<double> evaluate(List<Position> positions) {
    return Future.value(0); // TODO: implement evaluate
  }

  @override
  TransportType getTransportType() {
    return this.dataProvider.getTransportType();
  }
}
