import 'package:app_backend/controller/utils/position_utils.dart';
import 'package:app_backend/model/trip/leg.dart';
import 'package:app_backend/model/trip/tracked_point.dart';
import 'package:app_backend/model/trip/transport_type.dart';
import 'package:app_backend/model/trip/trip.dart';
import 'package:fling_units/fling_units.dart';

double metersPerLatDegree = PositionUtils.calculateDistance(0, 0, 1, 0);
double latDegreesPerMeter = 1 / metersPerLatDegree;

class TripBuilder {

  final List<Leg> _legs = List.empty(growable: true);
  List<TrackedPoint> _leg = List.empty(growable: true);
  bool skipStayPoints;
  // DateTime start = DateTime.now();
  DateTime time = DateTime.now();
  double latitude = 49.006889;
  double longitude = 8.403653;

  TripBuilder() : skipStayPoints = true;

  TripBuilder.withData(this.latitude, this.longitude, {this.skipStayPoints = true});

  TripBuilder stay(Duration duration) {
    DateTime end = time.add(duration);
    if (!skipStayPoints) {
      while (time.isBefore(end)) {
        _leg.add(TrackedPoint.withData(latitude, longitude, 0, time));
        time = time.add(Duration(seconds: 5));
      }
    } else {
      time = end;
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
    do {
      _leg.add(TrackedPoint.withData(
          latitude, longitude, speed.as(kilo.meters, hours), time));
      time = time.add(Duration(seconds: 5));
      latitude += latAddPer5Sec;
    } while (time.isBefore(end));
    _leg.add(TrackedPoint.withData(
        latitude, longitude, speed.as(kilo.meters, hours), time));
    latitude += latAddPer5Sec;
    return this;
  }

  TripBuilder leg({TransportType type = TransportType.by_foot}) {
    if (_leg.isNotEmpty) {
      _legs.add(Leg.withData(type, _leg));
    }
    _leg = List.empty(growable: true);
    return this;
  }

  List<TrackedPoint> collect() {
    this.leg();
    return this._legs.expand((element) => element.trackedPoints).toList();
  }

  Trip build() {
    this.leg();
    Trip built = Trip.withData(_legs);
    return built;
  }
}