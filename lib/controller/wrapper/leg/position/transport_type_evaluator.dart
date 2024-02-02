import 'package:app_backend/model/trip/leg.dart';
import 'package:app_backend/model/trip/transport_type.dart';

abstract class TransportTypeEvaluator {
  Future<double> evaluate(Leg leg);

  TransportType getTransportType();
}
