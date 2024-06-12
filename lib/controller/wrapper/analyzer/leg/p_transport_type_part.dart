import 'package:trekko_backend/controller/wrapper/analyzer/leg/transport/transport_type_part.dart';
import 'package:trekko_backend/model/tracking/position.dart';

class PTransportTypePart extends TransportTypePart {
  final Iterable<Position> included;

  PTransportTypePart(TransportTypePart part, this.included)
      : super(part.start, part.end, part.confidence, part.transportType);
}
