// Leave order and names as is!

enum BatteryUsageSetting {
  low(15),
  medium(10),
  high(5);

  final int interval;

  const BatteryUsageSetting(this.interval);
}
