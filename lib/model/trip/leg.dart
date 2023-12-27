import 'package:app_backend/model/trip/tracked_point.dart';
import 'package:app_backend/model/trip/transportation_type.dart';
import 'package:app_backend/model/trip/trip.dart';
import 'package:drift/drift.dart';

class Leg extends Table {

  IntColumn get id => integer().autoIncrement()();
  TextColumn get trip_id => text().references(Trip, #uid)();
  IntColumn get transportationType => intEnum<TransportationType>()();
  // will be filled by the db
  final List<TrackedPoint> points = [];

}