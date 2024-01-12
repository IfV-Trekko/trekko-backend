import 'package:app_backend/model/trip/tracked_point.dart';
import 'package:app_backend/model/trip/transport_type.dart';
import 'package:isar/isar.dart';

part 'leg.g.dart';

@embedded
class Leg {
  @enumerated
  final TransportType transportationType;
  final List<TrackedPoint> trackedPoints;

  Leg.withData(this.transportationType, this.trackedPoints);

  Leg()
      : transportationType = TransportType.car,
        trackedPoints = [];
}
