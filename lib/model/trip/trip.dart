import 'package:app_backend/controller/database/trip/trip_repository.dart';
import 'package:app_backend/model/trip/donation_state.dart';
import 'package:app_backend/model/trip/leg.dart';
import 'package:drift/drift.dart';

class Trip implements Insertable<Trip> {
  final String uid;
  final DonationState donationState;
  final DateTime startTime;
  final DateTime endTime;
  final String? comment;
  final String? purpose;
  final List<Leg> legs = [];

  Trip({
    required this.uid,
    required this.donationState,
    required this.startTime,
    required this.endTime,
    required this.comment,
    required this.purpose,
  });

  @override
  Map<String, Expression<Object>> toColumns(bool nullToAbsent) {
    return TripsCompanion(
      uid: Value(uid),
      donationState: Value(donationState),
      startTime: Value(startTime),
      endTime: Value(endTime),
      comment: Value(comment),
      purpose: Value(purpose),
    ).toColumns(nullToAbsent);
  }
}

@UseRowClass(Trip)
class Trips extends Table {
  TextColumn get uid => text()();

  IntColumn get donationState => intEnum<DonationState>()();

  DateTimeColumn get startTime => dateTime()();

  DateTimeColumn get endTime => dateTime()();

  TextColumn get comment => text().nullable()();

  TextColumn get purpose => text().nullable()();
}
