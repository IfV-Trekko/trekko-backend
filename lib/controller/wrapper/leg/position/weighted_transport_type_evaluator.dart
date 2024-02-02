import 'package:app_backend/controller/wrapper/leg/position/transport_type_data_provider.dart';
import 'package:app_backend/controller/wrapper/leg/position/transport_type_evaluator.dart';
import 'package:app_backend/model/trip/leg.dart';
import 'package:app_backend/model/trip/transport_type.dart';
import 'package:fling_units/fling_units.dart';

class WeightedTransportTypeEvaluator implements TransportTypeEvaluator {
  final TransportTypeDataProvider dataProvider;

  WeightedTransportTypeEvaluator(this.dataProvider);

  @override
  Future<double> evaluate(Leg leg) {
    return Future.microtask(() async {
      double providedSpeed =
          (await dataProvider.getAverageSpeed()).as(meters, seconds);
      double legSpeed = leg.getSpeed().as(meters, seconds);
      return legSpeed / providedSpeed;
    });
  }

  @override
  TransportType getTransportType() {
    return this.dataProvider.getTransportType();
  }
}
