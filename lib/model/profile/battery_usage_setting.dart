// Leave order and names as is!
import 'package:geolocator/geolocator.dart';

enum BatteryUsageSetting {
  low(LocationAccuracy.low),
  medium(LocationAccuracy.medium),
  high(LocationAccuracy.high);

  final LocationAccuracy accuracy;

  const BatteryUsageSetting(this.accuracy);
}
