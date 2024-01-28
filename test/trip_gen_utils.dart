import 'dart:math';

import 'package:app_backend/model/trip/tracked_point.dart';
import 'package:fling_units/fling_units.dart';
import 'package:geolocator/geolocator.dart';

// TODO: move to normal utilities?

double metersPerLongDegree = Geolocator.distanceBetween(0, 0, 0, 1);
double longDegreesPerMeter = 1 / metersPerLongDegree;
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
  double random = Random().nextDouble();
  return move(random, 1 - random, duration, distance);
}

List<TrackedPoint> move(
    double longPerc, double latPerc, Duration duration, Distance distance) {
  if (longPerc.abs() + latPerc.abs() != 1) {
    throw Exception("|longPerc + latPerc| must be 1");
  }

  List<TrackedPoint> leg = [];
  var speed = distance.per(duration.inSeconds.seconds);
  double addPer5Sec = speed.as(meters, seconds) * degreesPerMeter * 5;
  double longAddPer5Sec = addPer5Sec * longPerc;
  double latAddPer5Sec = addPer5Sec * latPerc;
  DateTime end = time.add(duration);
  while (time.isBefore(end)) {
    longitude += longAddPer5Sec;
    latitude += latAddPer5Sec;
    leg.add(TrackedPoint.withData(
        latitude, longitude, speed.as(kilo.meters, hours), time));
    time = time.add(Duration(seconds: 5));
  }
  return leg;
}
