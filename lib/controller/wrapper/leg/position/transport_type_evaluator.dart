import 'package:app_backend/model/trip/transport_type.dart';
import 'package:geolocator/geolocator.dart';

abstract class TransportTypeEvaluator {

    Future<double> evaluate(List<Position> positions);

    TransportType getTransportType();

}