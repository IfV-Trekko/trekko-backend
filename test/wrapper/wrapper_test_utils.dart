import 'package:app_backend/model/trip/tracked_point.dart';
import 'package:fling_units/fling_units.dart';
import 'package:geolocator/geolocator.dart';

double metersPerDegree = Geolocator.distanceBetween(0, 0, 0, 1);
double degreesPerMeter = 1 / metersPerDegree;

List<TrackedPoint> generateStay(
    double latitude, double longitude, DateTime time, Duration duration) {
  DateTime end = time.add(duration);
  List<TrackedPoint> stay = [];
  while (time.isBefore(end)) {
    stay.add(TrackedPoint.withData(latitude, longitude, 0, time));
    time = time.add(Duration(seconds: 5));
  }
  return stay;
}

List<TrackedPoint> generateLeg(
    double startLat,
    double startLong,
    Duration duration,
    DerivedMeasurement<Measurement<Distance>, Measurement<Time>> speed,
    DateTime time) {
  List<TrackedPoint> leg = [];
  double longAddPer5Sec = speed.as(meters, seconds) * degreesPerMeter * 5;
  double long = startLong;
  DateTime end = time.add(duration);
  while (time.isBefore(end)) {
    long += longAddPer5Sec;
    leg.add(TrackedPoint.withData(
        startLat, long, speed.as(kilo.meters, hours), time));
    time = time.add(Duration(seconds: 5));
  }
  return leg;
}