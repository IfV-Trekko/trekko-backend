import 'package:trekko_backend/model/trip/leg.dart';
import 'package:trekko_backend/model/trip/transport_type.dart';
import 'package:trekko_backend/model/trip/trip.dart';

class TripUtil {
  final TransportType type;

  TripUtil(this.type);

  Iterable<double> Function(Trip) build(double Function(Leg) apply) {
    return (trip) =>
        trip.getLegs().where((leg) => leg.transportType == type).map(apply);
  }
}
