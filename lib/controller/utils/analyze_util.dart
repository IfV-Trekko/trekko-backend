import 'package:trekko_backend/model/trip/leg.dart';
import 'package:trekko_backend/model/trip/transport_type.dart';
import 'package:trekko_backend/model/trip/trip.dart';

class TripUtil {
  final TransportType type;

  TripUtil(this.type);

  Iterable<double> Function(Trip) build(double Function(Leg) legFunction) {
    return (t) => t.legs.where((l) => l.transportType == type).map(legFunction);
  }
}
