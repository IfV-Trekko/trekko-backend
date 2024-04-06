// Leave order and names as is!

enum BatteryUsageSetting {
  low(60),
  medium(35),
  high(20);

  final int interval;

  const BatteryUsageSetting(this.interval);
}
