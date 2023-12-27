import 'package:app_backend/model/trip/leg.dart';
import 'package:drift/drift.dart';

class TrackedPoint extends Table {

  IntColumn get id => integer().autoIncrement()();
  TextColumn get leg_id => text().references(Leg, #id)();
  RealColumn get latitude => real()();
  RealColumn get longitude => real()();
  RealColumn get speed => real()();
  DateTimeColumn get timestamp => dateTime()();

}