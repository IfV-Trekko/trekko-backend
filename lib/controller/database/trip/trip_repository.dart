import 'package:app_backend/controller/utility/database_utils.dart';
import 'package:app_backend/model/trip/donation_state.dart';
import 'package:app_backend/model/trip/leg.dart';
import 'package:app_backend/model/trip/tracked_point.dart';
import 'package:app_backend/model/trip/transport_type.dart';
import 'package:app_backend/model/trip/trip.dart';
import 'package:drift/drift.dart';

part 'trip_repository.g.dart';

@DriftDatabase(tables: [Trips, Legs, TrackedPoints])
class TripRepository extends _$TripRepository {
  TripRepository() : super(DatabaseUtils.openConnection("trip"));

  @override
  int get schemaVersion => 1;

  Future addTrip(Trip trip) async {
    try {
      await transaction(() async {
        await into(trips).insert(trip);
        for (Leg leg in trip.legs) {
          await into(legs).insert(leg);
          for (TrackedPoint trackedPoint in leg.trackedPoints) {
            await into(trackedPoints).insert(trackedPoint);
          }
        }
      });
      return true;
    } catch (e) {
      print(e);
      return false;
    }
  }

  Stream<List<Trip>> watchTrips() => select(trips).watch();
}
