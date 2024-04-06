// Leave order and names as is!

enum BatteryUsageSetting {
  low(120),
  medium(50),
  high(20);

  final int interval;

  const BatteryUsageSetting(this.interval);
}
