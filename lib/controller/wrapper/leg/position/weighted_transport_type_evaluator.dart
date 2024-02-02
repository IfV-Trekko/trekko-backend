import 'dart:math';

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
          (await dataProvider.getAverageSpeed()).as(kilo.meters, hours);
      double legSpeed = leg.getSpeed().as(kilo.meters, hours);
      double distanceBetweenSpeeds = (providedSpeed - legSpeed).abs();
      // f(x) = -x^2 * 1 * 10^-6 + 1
      double calculated = -pow(distanceBetweenSpeeds, 2) * pow(10, -6) + 1;
      return max(calculated, 0);
    });
  }

  @override
  TransportType getTransportType() {
    return this.dataProvider.getTransportType();
  }
}
