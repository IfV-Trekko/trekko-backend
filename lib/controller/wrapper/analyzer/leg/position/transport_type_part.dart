import 'package:trekko_backend/controller/wrapper/analyzer/leg/position/transport_type_data.dart';

class TransportTypePart {
  final DateTime start;
  final DateTime end;
  final TransportTypeData transportType;

  TransportTypePart(this.start, this.end, this.transportType);

  Duration get duration => end.difference(start);
}
