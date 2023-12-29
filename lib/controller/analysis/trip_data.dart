import 'package:app_backend/model/trip/tracked_point.dart';
import 'package:app_backend/model/trip/trip.dart';
import 'package:geolocator/geolocator.dart';

enum TripData {
  distance_in_meters,
  duration_in_seconds,
  speed_in_kmh;

  double apply(Trip trip) {
    switch (this) {
      case TripData.distance_in_meters:
        double distance = 0;
        for (var leg in trip.legs) {
          for (int i = 1; i < leg.trackedPoints.length; i++) {
            TrackedPoint p0 = leg.trackedPoints[i - 1];
            TrackedPoint p1 = leg.trackedPoints[i];
            distance += Geolocator.distanceBetween(
                p0.latitude, p0.longitude, p1.latitude, p1.longitude);
          }
        }
        return distance;
      case TripData.duration_in_seconds:
        return trip.startTime.difference(trip.endTime).inSeconds.toDouble();
      case TripData.speed_in_kmh:
        return trip.legs
                .map((l) =>
                    l.trackedPoints
                        .map((t) => t.speed_in_kmh)
                        .reduce((a, b) => a + b) /
                    l.trackedPoints.length)
                .reduce((a, b) => a + b) /
            trip.legs.length;
    }
  }
}
