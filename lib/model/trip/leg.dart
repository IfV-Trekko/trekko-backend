import 'package:app_backend/model/trip/tracked_point.dart';
import 'package:app_backend/model/trip/transport_type.dart';
import 'package:isar/isar.dart';

part 'leg.g.dart';

@embedded
class Leg {
  @enumerated
  final TransportType transportType;
  final List<TrackedPoint> trackedPoints;

  Leg()
      : transportType = TransportType.car,
        trackedPoints = [];

  Leg.withData(this.transportType, this.trackedPoints) {
    if (this.trackedPoints.length < 2) {
      throw Exception("A leg must have at least two tracked points");
    }

    for (int i = 1; i < this.trackedPoints.length; i++) {
      if (this.trackedPoints[i].timestamp.isBefore(this.trackedPoints[i - 1].timestamp)) {
        throw Exception("The tracked points must be in chronological order");
      }
    }
  }
}
