import 'package:fling_units/fling_units.dart';
import 'package:trekko_backend/model/position_accuracy.dart';

// Leave order and names as is!
enum BatteryUsageSetting {
  low(60, PositionAccuracy.best, 40),
  medium(35, PositionAccuracy.best, 15),
  high(20, PositionAccuracy.best, 2);

  final int interval;
  final PositionAccuracy accuracy;
  final int distanceFilterMeters;

  const BatteryUsageSetting(this.interval, this.accuracy, this.distanceFilterMeters);

  Duration getInterval() {
    return Duration(seconds: interval);
  }

  Duration getAccelerometerInterval() {
    return Duration(seconds: 1);
  }

  Duration getGyroscopeInterval() {
    return Duration(seconds: 1);
  }

  Distance getDistanceFilter() {
    return distanceFilterMeters.meters;
  }
}
