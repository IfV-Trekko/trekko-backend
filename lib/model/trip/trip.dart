import 'package:app_backend/model/trip/donation_state.dart';
import 'package:app_backend/model/trip/leg.dart';
import 'package:app_backend/model/trip/tracked_point.dart';
import 'package:app_backend/model/trip/transport_type.dart';
import 'package:fling_units/fling_units.dart';
import 'package:isar/isar.dart';

part 'trip.g.dart';

@collection
class Trip {
  Id _id = Isar.autoIncrement;
  @enumerated
  DonationState _donationState = DonationState.undefined;
  List<Leg> _legs = List.empty(growable: true);
  DateTime? _startTime;
  DateTime? _endTime;
  double? _distanceInMeters;
  String? _comment;
  String? _purpose;

  Trip();

  /// Creates a new trip
  Trip.withData(List<Leg> legs) {
    this.legs = legs;
  }

  set id(Id id) => this._id = id;

  Id get id => this._id;

  set donationState(DonationState donationState) =>
      this._donationState = donationState;

  @enumerated
  DonationState get donationState => this._donationState;

  /// Returns the start time of the trip
  DateTime? get startTime => this._startTime;

  /// Returns the end time of the trip
  DateTime? get endTime => this._endTime;

  DateTime calculateStartTime() {
    return this._startTime ?? this.legs.first.calculateStartTime();
  }

  DateTime calculateEndTime() {
    return this._endTime ?? this.legs.last.calculateEndTime();
  }

  /// Sets the start time of the trip
  set startTime(DateTime? startTime) {
    if (this.endTime != null && this.calculateEndTime().isBefore(startTime!)) {
      throw Exception("The start time must be before the end time");
    }

    this._startTime = startTime;
  }

  /// Sets the end time of the trip
  set endTime(DateTime? endTime) {
    if (this._startTime != null &&
        this.calculateStartTime().isAfter(endTime!)) {
      throw Exception("The end time must be after the start time");
    }

    this._endTime = endTime;
  }

  double? get distanceInMeters => this._distanceInMeters;

  set distanceInMeters(double? distanceInMeters) =>
      this._distanceInMeters = distanceInMeters;

  /// Returns the distance of the trip
  Distance getDistance() => this._distanceInMeters != null
      ? this._distanceInMeters!.meters
      : Distance.sum(legs.map((e) => e.getDistance()));

  /// Set the distance of the trip
  setDistance(Distance distance) {
    if (distance.as(meters) <= 0) {
      throw Exception("Invalid distance");
    }

    this._distanceInMeters = distance.as(meters);
  }

  /// Set the purpose of the trip
  set purpose(String? purpose) => this._purpose = purpose;

  /// Get the purpose of the trip
  String? get purpose => this._purpose;

  /// Set the comment of the trip
  set comment(String? comment) => this._comment = comment;

  /// Get the comment of the trip
  String? get comment => this._comment;

  /// Returns the average speed of the trip
  DerivedMeasurement<Measurement<Distance>, Measurement<Time>> getSpeed() =>
      this.getDistance().per(this.getDuration().inSeconds.seconds);

  /// Returns the duration of the trip
  Duration getDuration() =>
      this.calculateEndTime().difference(this.calculateStartTime());

  /// Returns the legs of the trip
  List<Leg> get legs => this._legs;

  /// Set the legs of the trip
  set legs(List<Leg> legs) {
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

    this._legs = legs;
  }

  /// Returns the transport types of the trip
  List<TransportType> getTransportTypes() =>
      this.legs.map((e) => e.transportType).toList();
}
