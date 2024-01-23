import 'package:app_backend/model/trip/donation_state.dart';
import 'package:app_backend/model/trip/leg.dart';
import 'package:app_backend/model/trip/tracked_point.dart';
import 'package:app_backend/model/trip/transport_type.dart';
import 'package:isar/isar.dart';

part 'trip.g.dart';

@collection
class Trip {
  Id id = Isar.autoIncrement;
  @enumerated
  DonationState donationState;
  DateTime startTime;
  DateTime endTime;
  String? comment;
  String? purpose;
  List<Leg> legs;

  Trip({
    required this.donationState,
    required this.startTime,
    required this.endTime,
    required this.comment,
    required this.purpose,
    required this.legs,
  });
  
  List<TransportType> getTransportTypes() {
    return this.legs.map((e) => e.transportType).toList();
  }
}
 