import 'package:app_backend/model/trip/leg.dart';
import 'package:app_backend/model/trip/tracked_point.dart';
import 'package:app_backend/model/trip/transport_type.dart';
import 'package:app_backend/model/trip/trip.dart';
import 'package:fling_units/fling_units.dart';
import 'package:geolocator/geolocator.dart';

double metersPerLatDegree = Geolocator.distanceBetween(0, 0, 1, 0);
double latDegreesPerMeter = 1 / metersPerLatDegree;

class TripBuilder {

  final List<Leg> _legs = List.empty(growable: true);
  List<TrackedPoint> _leg = List.empty(growable: true);
  DateTime time = DateTime.now();
  double latitude = 49.006889;
  double longitude = 8.403653;

  TripBuilder();

  TripBuilder.withData(this.latitude, this.longitude);

  TripBuilder stay(Duration duration) {
    DateTime end = time.add(duration);
    while (time.isBefore(end)) {
      _leg.add(TrackedPoint.withData(latitude, longitude, 0, time));
      time = time.add(Duration(seconds: 5));
    }
    return this;
  }

  TripBuilder move_r(Duration duration, Distance distance) {
    return move(true, duration, distance);
  }

  TripBuilder move(
      bool forward, Duration duration, Distance distance) {
    var speed = distance.per(duration.inSeconds.seconds);
    var speedAsMetersPerSecond = speed.as(meters, seconds);
    double forwardMultiplier = forward ? 1 : -1;
    double latAddPer5Sec = speedAsMetersPerSecond * latDegreesPerMeter * 5 * forwardMultiplier;
    DateTime end = time.add(duration);
    while (time.isBefore(end)) {
      _leg.add(TrackedPoint.withData(
          latitude, longitude, speed.as(kilo.meters, hours), time));
      latitude += latAddPer5Sec;
      time = time.add(Duration(seconds: 5));
    }
    _leg.add(TrackedPoint.withData(
        latitude, longitude, speed.as(kilo.meters, hours), time));
    return this;
  }

  TripBuilder leg() {
    if (_leg.isNotEmpty) {
      _legs.add(Leg.withData(TransportType.by_foot, _leg));
    }
    _leg = List.empty(growable: true);
    return this;
  }

  Trip build() {
    this.leg();
    return Trip.withData(_legs);
  }
}