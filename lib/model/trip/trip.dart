import 'package:trekko_backend/model/trip/donation_state.dart';
import 'package:trekko_backend/model/trip/leg.dart';
import 'package:trekko_backend/model/trip/position_collection.dart';
import 'package:trekko_backend/model/trip/tracked_point.dart';
import 'package:trekko_backend/model/trip/transport_type.dart';
import 'package:fling_units/fling_units.dart';
import 'package:isar/isar.dart';

part 'trip.g.dart';

@collection
class Trip extends PositionCollection {
  Id id = Isar.autoIncrement;
  @enumerated
  DonationState donationState = DonationState.undefined;
  late List<Leg> legs;
  String? comment;
  String? purpose;

  Trip();

  /// Creates a new trip
  Trip.withData(List<Leg> legs) {
    if (legs.isEmpty) {
      throw Exception("A trip must have at least one leg");
    }

    for (int i = 1; i < legs.length; i++) {
      if (legs[i]
          .calculateStartTime()
          .isBefore(legs[i - 1].calculateEndTime())) {
        throw Exception("The legs must be in chronological order");
      }
    }

    this.legs = legs;
  }

  @override
  DateTime calculateStartTime() {
    return this.legs.first.calculateStartTime();
  }

  @override
  DateTime calculateEndTime() {
    return this.legs.last.calculateEndTime();
  }

  @override
  Distance calculateDistance() {
    return Distance.sum(legs.map((e) => e.calculateDistance()));
  }

  @override
  List<TransportType> calculateTransportTypes() {
    return this.legs.expand((e) => e.calculateTransportTypes()).toSet().toList();
  }

  @override
  List<Leg> getLegs() {
    return List.from(this.legs);
  }
}
