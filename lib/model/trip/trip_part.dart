import 'package:app_backend/model/trip/tracked_point.dart';
import 'package:app_backend/model/trip/transportation_type.dart';

class TripPart {
  final TransportationType transportationType;
  final List<TrackedPoint> points;

  TripPart(this.transportationType, this.points);

}