import 'package:app_backend/controller/utility/database_utils.dart';
import 'package:app_backend/model/trip/donation_state.dart';
import 'package:app_backend/model/trip/leg.dart';
import 'package:app_backend/model/trip/tracked_point.dart';
import 'package:app_backend/model/trip/transportation_type.dart';
import 'package:app_backend/model/trip/trip.dart';
import 'package:drift/drift.dart';

part 'trip_repository.g.dart';

@DriftDatabase(tables: [Trip, Leg, TrackedPoint])
class TripRepository extends _$TripRepository {

  TripRepository() : super(DatabaseUtils.openConnection("trip"));

  @override
  int get schemaVersion => 1;

}

