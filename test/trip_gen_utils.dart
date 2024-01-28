import 'package:app_backend/model/trip/tracked_point.dart';
import 'package:fling_units/fling_units.dart';
import 'package:geolocator/geolocator.dart';

// TODO: move to normal utilities?

double metersPerLatDegree = Geolocator.distanceBetween(0, 0, 1, 0);
double latDegreesPerMeter = 1 / metersPerLatDegree;
DateTime time = DateTime.now();
double latitude = 0;
double longitude = 0;

List<TrackedPoint> stay(Duration duration) {
  DateTime end = time.add(duration);
  List<TrackedPoint> stay = [];
  while (time.isBefore(end)) {
    stay.add(TrackedPoint.withData(latitude, longitude, 0, time));
    time = time.add(Duration(seconds: 5));
  }
  return stay;
}

List<TrackedPoint> move_r(Duration duration, Distance distance) {
  return move(true, duration, distance);
}

List<TrackedPoint> move(
    bool forward, Duration duration, Distance distance) {
  List<TrackedPoint> leg = [];
  var speed = distance.per(duration.inSeconds.seconds);
  var speedAsMetersPerSecond = speed.as(meters, seconds);
  double forwardMultiplier = forward ? 1 : -1;
  double latAddPer5Sec = speedAsMetersPerSecond * latDegreesPerMeter * 5 * forwardMultiplier;
  DateTime end = time.add(duration);
  while (time.isBefore(end)) {
    leg.add(TrackedPoint.withData(
        latitude, longitude, speed.as(kilo.meters, hours), time));
    latitude += latAddPer5Sec;
    time = time.add(Duration(seconds: 5));
  }
  leg.add(TrackedPoint.withData(
      latitude, longitude, speed.as(kilo.meters, hours), time));
  return leg;
}
