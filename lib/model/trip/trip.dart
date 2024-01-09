import 'package:app_backend/model/trip/donation_state.dart';
import 'package:app_backend/model/trip/leg.dart';
import 'package:app_backend/model/trip/tracked_point.dart';
import 'package:isar/isar.dart';

part 'trip.g.dart';

@collection
class Trip {

  final Id id = Isar.autoIncrement;
  @enumerated
  final DonationState donationState;
  final DateTime startTime;
  final DateTime endTime;
  final String? comment;
  final String? purpose;
  final List<Leg> legs;

  Trip({
    required this.donationState,
    required this.startTime,
    required this.endTime,
    required this.comment,
    required this.purpose,
    required this.legs,
  });
}
