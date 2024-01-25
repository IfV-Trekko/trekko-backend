import 'package:app_backend/model/trip/trip.dart';
import 'package:fling_units/fling_units.dart';

enum TripData {
  distance_in_meters,
  duration_in_seconds,
  speed_in_kmh;

  double apply(Trip trip) {
    switch (this) {
      case TripData.distance_in_meters:
        return trip.getDistance().as(meters);
      case TripData.duration_in_seconds:
        return trip.getDuration().inSeconds.toDouble();
      case TripData.speed_in_kmh:
        return trip.getSpeed().as(kilo.meters, hours);
    }
  }
}
