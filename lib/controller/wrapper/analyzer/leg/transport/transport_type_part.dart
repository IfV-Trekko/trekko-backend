import 'package:trekko_backend/controller/wrapper/analyzer/leg/transport/transport_type_data_provider.dart';
import 'package:trekko_backend/model/tracking/position.dart';

class TransportTypePart {
  final DateTime start;
  final DateTime end;
  final double confidence;
  final TransportTypeDataProvider transportType;
  final Iterable<Position> included;

  TransportTypePart(
      this.start, this.end, this.confidence, this.transportType, this.included);

  Duration get duration => end.difference(start);
}
