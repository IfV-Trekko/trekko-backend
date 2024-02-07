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
  late List<Leg> _legs;
  List<String>? _transportTypes;
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
    return this.legs.first.calculateStartTime();
  }

  DateTime calculateEndTime() {
    return this.legs.last.calculateEndTime();
  }

  DateTime getStartTime() {
    return this._startTime ?? calculateStartTime();
  }

  DateTime getEndTime() {
    return this._endTime ?? calculateEndTime();
  }

  /// Sets the start time of the trip
  set startTime(DateTime? startTime) {
    if (this.endTime != null &&
        startTime != null &&
        this.getEndTime().isBefore(startTime)) {
      throw Exception("The start time must be before the end time");
    }

    this._startTime = startTime;
  }

  /// Sets the end time of the trip
  set endTime(DateTime? endTime) {
    if (this._startTime != null &&
        endTime != null &&
        this.getStartTime().isAfter(endTime)) {
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
      : calculateDistance();

  Distance calculateDistance() {
    return Distance.sum(legs.map((e) => e.getDistance()));
  }

  /// Set the distance of the trip
  setDistance(Distance? distance) {
    if (distance == null) {
      this.distanceInMeters = null;
      return;
    }

    if (distance.as(meters) <= 0) {
      throw Exception("Invalid distance");
    }

    this.distanceInMeters = distance.as(meters);
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
  DerivedMeasurement<Measurement<Distance>, Measurement<Time>>
      calculateSpeed() =>
          this.getDistance().per(this.calculateDuration().inSeconds.seconds);

  /// Returns the duration of the trip
  Duration calculateDuration() =>
      this.getEndTime().difference(this.getStartTime());

  /// Returns the legs of the trip
  List<Leg> get legs => this._legs;

  /// Set the legs of the trip
  set legs(List<Leg> legs) {
    // if (legs.isEmpty) {
    //   throw Exception("A trip must have at least one leg");
    // }

    for (int i = 1; i < legs.length; i++) {
      if (legs[i]
          .calculateStartTime()
          .isBefore(legs[i - 1].calculateEndTime())) {
        throw Exception("The legs must be in chronological order");
      }
    }

    this._legs = legs;
  }

  List<String>? get transportTypes => this._transportTypes;

  set transportTypes(List<String>? transportTypes) {
    this._transportTypes = transportTypes;
  }

  /// Returns the transport types of the trip
  List<TransportType> getTransportTypes() => this._transportTypes != null
      ? this
          ._transportTypes!
          .map((e) => TransportType.values
              .firstWhere((element) => element.toString() == e))
          .toList()
      : calculateTransportTypes();

  List<TransportType> calculateTransportTypes() {
    return this.legs.map((e) => e.transportType).toList();
  }

  // Sets the transport types of the trip
  setTransportTypes(List<TransportType> transportTypes) {
    this.transportTypes = transportTypes.map((e) => e.name).toList();
  }

  void reset() {
    this._startTime = null;
    this._endTime = null;
    this._distanceInMeters = null;
    this._transportTypes = null;
    this._comment = null;
    this._purpose = null;
  }
}
