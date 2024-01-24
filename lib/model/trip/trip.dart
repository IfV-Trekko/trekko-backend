import 'package:app_backend/model/trip/donation_state.dart';
import 'package:app_backend/model/trip/leg.dart';
import 'package:app_backend/model/trip/tracked_point.dart';
import 'package:app_backend/model/trip/transport_type.dart';
import 'package:geolocator/geolocator.dart';
import 'package:isar/isar.dart';

part 'trip.g.dart';

@collection
class Trip {
  Id id = Isar.autoIncrement;
  @enumerated
  DonationState donationState;
  String? comment;
  String? purpose;
  List<Leg> legs;

  Trip({
    required this.donationState,
    required this.comment,
    required this.purpose,
    required this.legs,
  }) {
    if (this.legs.isEmpty) {
      throw Exception("A trip must have at least one leg");
    }
  }

  DateTime getStartTime() {
    return this.legs.first.trackedPoints.first.timestamp;
  }

  DateTime getEndTime() {
    return this.legs.last.trackedPoints.last.timestamp;
  }

  double getDistanceInMeters() {
    double distance = 0;
    for (var leg in legs) {
      for (int i = 1; i < leg.trackedPoints.length; i++) {
        TrackedPoint p0 = leg.trackedPoints[i - 1];
        TrackedPoint p1 = leg.trackedPoints[i];
        distance += Geolocator.distanceBetween(
            p0.latitude, p0.longitude, p1.latitude, p1.longitude);
      }
    }
    return distance;
  }

  double getSpeedInKmh() {
    double distance = this.getDistanceInMeters();
    Duration duration = this.getDuration();
    return distance / duration.inSeconds * 3.6;
  }

  Duration getDuration() {
    return this.getEndTime().difference(this.getStartTime());
  }
  
  List<TransportType> getTransportTypes() {
    return this.legs.map((e) => e.transportType).toList();
  }
}
 