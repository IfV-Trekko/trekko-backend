import 'package:isar/isar.dart';
import 'package:trekko_backend/model/profile/battery_usage_setting.dart';

part 'tracking_options.g.dart';

@collection
class TrackingOptions {

  @Index(unique: true, replace: true)
  Id id = Id.parse("1");
  @enumerated
  late BatteryUsageSetting batterySettings;

  TrackingOptions(this.batterySettings);

}