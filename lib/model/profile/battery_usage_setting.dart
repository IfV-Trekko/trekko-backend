// Leave order and names as is!

import 'package:background_locator_2/settings/locator_settings.dart';

enum BatteryUsageSetting {
  low(LocationAccuracy.LOW),
  medium(LocationAccuracy.BALANCED),
  high(LocationAccuracy.HIGH);

  final LocationAccuracy accuracy;

  const BatteryUsageSetting(this.accuracy);
}
