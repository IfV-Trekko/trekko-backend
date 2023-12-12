import 'package:app_backend/model/trip/donation_state.dart';
import 'package:app_backend/model/trip/trip_part.dart';

class Trip {

  final String uid;
  final String id;
  final String? comment;
  final String? purpose;
  final List<TripPart> tripParts;
  final DonationState donationState;

  Trip(this.uid, this.id, this.comment, this.purpose, this.tripParts, this.donationState);

}