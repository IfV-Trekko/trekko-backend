import 'package:app_backend/model/trip/leg.dart';

abstract class TransportTypeEvaluator {
  Future<double> evaluate(Leg leg);
}
