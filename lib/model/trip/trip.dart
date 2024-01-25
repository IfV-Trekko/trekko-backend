import 'package:app_backend/model/trip/donation_state.dart';
import 'package:app_backend/model/trip/leg.dart';
import 'package:app_backend/model/trip/tracked_point.dart';
import 'package:app_backend/model/trip/transport_type.dart';
import 'package:fling_units/fling_units.dart';
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

  Distance getDistance() {
    return Distance.sum(legs.map((e) => e.getDistance()));
  }

  DerivedMeasurement<Measurement<Distance>, Measurement<Time>> getSpeed() {
    return this.getDistance().per(this.getDuration().inSeconds.seconds);
  }

  Duration getDuration() {
    return this.getEndTime().difference(this.getStartTime());
  }

  List<TransportType> getTransportTypes() {
    return this.legs.map((e) => e.transportType).toList();
  }
}
