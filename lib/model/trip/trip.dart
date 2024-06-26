import 'package:json_annotation/json_annotation.dart';
import 'package:trekko_backend/model/trip/donation_state.dart';
import 'package:trekko_backend/model/trip/leg.dart';
import 'package:trekko_backend/model/trip/position_collection.dart';
import 'package:trekko_backend/model/trip/tracked_point.dart';
import 'package:trekko_backend/model/trip/transport_type.dart';
import 'package:fling_units/fling_units.dart';
import 'package:isar/isar.dart';

part 'trip.g.dart';

@JsonSerializable()
@collection
class Trip extends PositionCollection {

  @JsonKey(name: 'id', includeToJson: false, includeFromJson: false)
  Id id = Isar.autoIncrement;

  @JsonKey(name: 'donationState')
  @enumerated
  DonationState donationState = DonationState.undefined;

  @JsonKey(name: 'legs')
  late List<Leg> legs;

  @JsonKey(name: 'comment')
  String? comment;

  @JsonKey(name: 'purpose')
  String? purpose;

  Trip();

  /// Creates a new trip
  Trip.withData(List<Leg> legs) {
    for (int i = 1; i < legs.length; i++) {
      DateTime start = legs[i].calculateStartTime();
      DateTime prevStart = legs[i - 1].calculateStartTime();
      if (start.isBefore(prevStart)) {
        throw Exception(
            "The legs must be in chronological order, timestamps $start should not be before $prevStart");
      }
    }

    this.legs = legs;
  }

  factory Trip.fromJson(Map<String, dynamic> json) => _$TripFromJson(json);

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
    return this
        .legs
        .expand((e) => e.calculateTransportTypes())
        .toSet()
        .toList();
  }

  @override
  List<Leg> getLegs() {
    return List.from(this.legs);
  }

  @override
  TransportType calculateMostUsedType() {
    Map<Leg, Distance> distances = Map.fromIterable(this.legs,
        key: (e) => e, value: (e) => e.calculateDistance());
    return this
        .legs
        .reduce((value, element) =>
            distances[value]! > distances[element]! ? value : element)
        .calculateMostUsedType();
  }

  @override
  bool deepEquals(PositionCollection other) {
    if (!(other is Trip)) return false;

    if (this.legs.length != other.legs.length) {
      return false;
    }

    for (int i = 0; i < this.legs.length; i++) {
      if (!this.legs[i].deepEquals(other.legs[i])) {
        return false;
      }
    }

    return other.comment == this.comment &&
        other.purpose == this.purpose &&
        other.donationState == this.donationState;
  }

  Map<String, dynamic> toJson() => _$TripToJson(this);
}
