import 'package:app_backend/controller/wrapper/leg/position/transport_type_data_provider.dart';
import 'package:app_backend/controller/wrapper/leg/position/transport_type_evaluator.dart';
import 'package:app_backend/model/trip/transport_type.dart';
import 'package:geolocator/geolocator.dart';

class WeightedTransportTypeEvaluator implements TransportTypeEvaluator {
  final TransportTypeDataProvider dataProvider;

  WeightedTransportTypeEvaluator(this.dataProvider);

  @override
  Future<double> evaluate(List<Position> positions) {
    double sum = 0;
    double max = 0;
    for (int i = 0; i < positions.length - 1; i++) {
      sum += positions[i].speed;
      if (positions[i].speed > max) max = positions[i].speed;
    }
    double averageSpeed = sum / positions.length;
    double maximumSpeed = max;
    double averageSpeedWeight = 0.5;
    double maximumSpeedWeight = 0.5;
    double averageSpeedFactor = averageSpeed / averageSpeedWeight;
    double maximumSpeedFactor = maximumSpeed / maximumSpeedWeight;
    double averageSpeedProbability = averageSpeedFactor / 100;
    double maximumSpeedProbability = maximumSpeedFactor / 100;
    double probability = (averageSpeedProbability + maximumSpeedProbability) / 2;
    return Future.value(probability);
  }

  @override
  TransportType getTransportType() {
    return this.dataProvider.getTransportType();
  }
}
