import 'package:isar/isar.dart';

part 'tracked_point.g.dart';

@embedded
class TrackedPoint {
  final double latitude;
  final double longitude;
  final double speed;
  final DateTime timestamp;

  TrackedPoint() : latitude = 0, longitude = 0, speed = 0, timestamp = DateTime.now();
}
