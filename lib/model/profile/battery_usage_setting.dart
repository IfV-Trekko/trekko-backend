import 'package:fling_units/fling_units.dart';
import 'package:geolocator/geolocator.dart';

// Leave order and names as is!
enum BatteryUsageSetting {
  low(60, LocationAccuracy.best, 40),
  medium(35, LocationAccuracy.best, 15),
  high(20, LocationAccuracy.best, 2);

  final int interval;
  final LocationAccuracy accuracy;
  final int distanceFilterMeters;

  const BatteryUsageSetting(this.interval, this.accuracy, this.distanceFilterMeters);

  Duration getInterval() {
    return Duration(seconds: interval);
  }

  Distance getDistanceFilter() {
    return distanceFilterMeters.meters;
  }
}
