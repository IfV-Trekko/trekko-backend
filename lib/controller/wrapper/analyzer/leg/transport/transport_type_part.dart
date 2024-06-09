import 'package:trekko_backend/controller/wrapper/analyzer/leg/transport/transport_type_data.dart';

class TransportTypePart {
  final DateTime start;
  final DateTime end;
  final double confidence;
  final TransportTypeData transportType;

  TransportTypePart(this.start, this.end, this.confidence, this.transportType);

  Duration get duration => end.difference(start);
}
