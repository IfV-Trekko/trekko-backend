import 'package:app_backend/controller/database/trip/trip_repository.dart';
import 'package:app_backend/model/trip/tracked_point.dart';
import 'package:app_backend/model/trip/transport_type.dart';
import 'package:app_backend/model/trip/trip.dart';
import 'package:drift/drift.dart';

class Leg implements Insertable<Leg> {
  final int id;
  final String trip_id;
  final TransportType transportationType;
  final List<TrackedPoint> trackedPoints = [];

  Leg(this.id, this.trip_id, this.transportationType);

  @override
  Map<String, Expression<Object>> toColumns(bool nullToAbsent) {
    return LegsCompanion(
      id: Value(id),
      trip_id: Value(trip_id),
      transportationType: Value(transportationType),
    ).toColumns(nullToAbsent);
  }
}

@UseRowClass(Leg)
class Legs extends Table {
  IntColumn get id => integer().autoIncrement()();

  TextColumn get trip_id => text().references(Trips, #uid)();

  IntColumn get transportationType => intEnum<TransportType>()();
}
