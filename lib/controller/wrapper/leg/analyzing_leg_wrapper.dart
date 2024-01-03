import 'package:app_backend/controller/wrapper/leg/leg_wrapper.dart';
import 'package:app_backend/controller/wrapper/leg/position/transport_type_data.dart';
import 'package:app_backend/controller/wrapper/leg/position/weighted_transport_type_evaluator.dart';
import 'package:app_backend/model/trip/leg.dart';
import 'package:app_backend/model/trip/tracked_point.dart';
import 'package:geolocator/geolocator.dart';

class AnalyzingLegWrapper implements LegWrapper {
  final List<Position> positions = [];

  Future<double> calculateProbability(TransportTypeData data) {
    WeightedTransportTypeEvaluator evaluator =
        WeightedTransportTypeEvaluator(data);
    return evaluator.evaluate(positions);
  }

  @override
  Future<double> calculateEndProbability() {
    // TODO: implement calculateEndProbability
    return Future.value(0);
  }

  @override
  add(Position position) async {
    positions.add(position);
  }

  @override
  int collectedDataPoints() {
    return positions.length;
  }

  @override
  Future<Leg> get() async {
    double maxProbability = 0;
    TransportTypeData maxData = TransportTypeData.foot;
    for (TransportTypeData data in TransportTypeData.values) {
      double probability = await calculateProbability(data);
      if (probability > maxProbability) {
        maxProbability = probability;
        maxData = data;
      }
    }

    Leg leg = Leg.fromTransportType(maxData.getTransportType());
    positions.map(TrackedPoint.fromPosition).forEach((tp) => leg.trackedPoints.add(tp));
    return Future.value(leg);
  }
}
