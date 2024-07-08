import 'package:fling_units/fling_units.dart';
import 'package:flutter_activity_recognition/models/activity_confidence.dart';
import 'package:flutter_activity_recognition/models/activity_type.dart';
import 'package:trekko_backend/controller/utils/position_utils.dart';
import 'package:trekko_backend/model/tracking/activity_data.dart';
import 'package:trekko_backend/model/tracking/position.dart';
import 'package:trekko_backend/model/tracking/raw_phone_data.dart';

double metersPerLatDegree = PositionUtils.calculateDistance(0, 0, 1, 0);
double latDegreesPerMeter = 1 / metersPerLatDegree;

class DataBuilder {
  final Duration positionInterval = Duration(seconds: 30);
  final DerivedMeasurement<Measurement<Distance>, Measurement<Time>>
      walkingSpeed = 5.kilo.meters.per(1.hours);

  final List<RawPhoneData> data = [];
  Position _position = Position(
      latitude: 49.006889,
      longitude: 8.403653,
      timestamp: DateTime.now(),
      accuracy: 5);

  void _activity(ActivityType type) {
    data.add(ActivityData(
        activity: type,
        confidence: ActivityConfidence.HIGH,
        timestamp: _position.timestamp));
  }

  DataBuilder _move(bool forward, Time duration, Distance distance) {
    var speed = distance.per(duration).as(meters, seconds);
    double steps = (duration.as(seconds) / positionInterval.inSeconds);
    var metersPerStep = speed * positionInterval.inSeconds;
    data.add(Position(
        latitude: _position.latitude,
        longitude: _position.longitude,
        timestamp: _position.timestamp.add(Duration(seconds: 1)),
        accuracy: _position.accuracy));

    for (int i = 0; i < steps.floor(); i++) {
      _position = Position(
          latitude: _position.latitude + latDegreesPerMeter * metersPerStep,
          longitude: _position.longitude,
          timestamp: _position.timestamp.add(positionInterval),
          accuracy: _position.accuracy);
      data.add(_position);
    }

    var restStep = steps - steps.floor();
    if (restStep != 0) {
      _position = Position(
          latitude: _position.latitude +
              latDegreesPerMeter * (metersPerStep * restStep),
          longitude: _position.longitude,
          timestamp: _position.timestamp.add(positionInterval * restStep),
          accuracy: 5);
      data.add(_position);
    }
    return this;
  }

  DataBuilder walk(Distance distance, {bool forward = true}) {
    _activity(ActivityType.WALKING);
    var duration =
        (distance.as(meters) / walkingSpeed.as(meters, seconds)).seconds;
    return _move(forward, duration, distance);
  }

  DataBuilder stay(Time duration) {
    _activity(ActivityType.STILL);
    return _move(true, duration, 0.meters);
  }

  List<RawPhoneData> collect() {
    return data;
  }
}
