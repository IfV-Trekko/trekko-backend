import 'package:app_backend/model/trip/trip.dart';

class ServerTrip {

  final String uid;
  final int startTimestamp;
  final int endTimestamp;
  final double distance;
  final List<String> transportTypes;
  final String? purpose;
  final String? comment;

  ServerTrip(this.uid, this.startTimestamp, this.endTimestamp, this.distance, this.transportTypes, this.purpose, this.comment);

  ServerTrip.fromTrip(Trip trip) :
    uid = trip.id.toString(),
    startTimestamp = trip.startTime.millisecondsSinceEpoch,
    endTimestamp = trip.endTime.millisecondsSinceEpoch,
    distance = 0, // TODO: Calculate distance
    transportTypes = trip.legs.map((e) => e.transportationType.toString()).toList(),
    purpose = trip.purpose,
    comment = trip.comment;

}