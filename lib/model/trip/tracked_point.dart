import 'package:app_backend/controller/database/trip/trip_repository.dart';
import 'package:app_backend/model/trip/leg.dart';
import 'package:drift/drift.dart';

class TrackedPoint implements Insertable<TrackedPoint> {

  final int id;
  final int leg_id;
  final double latitude;
  final double longitude;
  final double speed;
  final DateTime timestamp;

  TrackedPoint({
    required this.id,
    required this.leg_id,
    required this.latitude,
    required this.longitude,
    required this.speed,
    required this.timestamp,
  });

  @override
  Map<String, Expression<Object>> toColumns(bool nullToAbsent) {
    return TrackedPointsCompanion(
      id: Value(id),
      leg_id: Value(leg_id),
      latitude: Value(latitude),
      longitude: Value(longitude),
      speed: Value(speed),
      timestamp: Value(timestamp),
    ).toColumns(nullToAbsent);
  }

}

@UseRowClass(TrackedPoint)
class TrackedPoints extends Table {

  IntColumn get id => integer().autoIncrement()();
  IntColumn get leg_id => integer().references(Legs, #id)();
  RealColumn get latitude => real()();
  RealColumn get longitude => real()();
  RealColumn get speed => real()();
  DateTimeColumn get timestamp => dateTime()();

}