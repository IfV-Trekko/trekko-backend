import 'package:app_backend/model/trip/donation_state.dart';
import 'package:app_backend/model/trip/leg.dart';
import 'package:drift/drift.dart';

class Trip extends Table {

  TextColumn get uid => text()();
  IntColumn get donationState => intEnum<DonationState>()();
  TextColumn get comment => text().nullable()();
  TextColumn get purpose => text().nullable()();
  // will be filled by the db
  final List<Leg> legs = [];

}