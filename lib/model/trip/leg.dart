import 'package:json_annotation/json_annotation.dart';
import 'package:trekko_backend/controller/utils/position_utils.dart';
import 'package:trekko_backend/model/tracking/position.dart';
import 'package:trekko_backend/model/trip/position_collection.dart';
import 'package:trekko_backend/model/trip/tracked_point.dart';
import 'package:trekko_backend/model/trip/transport_type.dart';
import 'package:fling_units/fling_units.dart';
import 'package:isar/isar.dart';

part 'leg.g.dart';

@JsonSerializable()
@embedded
class Leg extends PositionCollection {

  @JsonKey(name: 'transportType')
  @enumerated
  TransportType transportType;

  @JsonKey(name: 'trackedPoints')
  List<TrackedPoint> trackedPoints;

  /// Creates a new leg
  Leg()
      : transportType = TransportType.car,
        trackedPoints = List.empty(growable: true);

  factory Leg.fromJson(Map<String, dynamic> json) => _$LegFromJson(json);

  /// Creates a leg with the given data
  Leg.withData(this.transportType, this.trackedPoints) {
    Position? notInOrder = PositionUtils.checkInOrder(
        this.trackedPoints.map((e) => e.toPosition()));
    if (notInOrder != null) {
      throw Exception(
          "The tracked points must be in chronological order - timestamp of the first out-of-order point: ${notInOrder.timestamp}");
    }
  }

  @override
  DateTime calculateStartTime() {
    return this.trackedPoints.first.timestamp;
  }

  @override
  DateTime calculateEndTime() {
    return this.trackedPoints.last.timestamp;
  }

  @override
  Distance calculateDistance() {
    double distanceInMeters = 0;
    for (int i = 1; i < trackedPoints.length; i++) {
      TrackedPoint p0 = trackedPoints[i - 1];
      TrackedPoint p1 = trackedPoints[i];
      distanceInMeters += PositionUtils.calculateDistance(
          p0.latitude, p0.longitude, p1.latitude, p1.longitude);
    }
    return distanceInMeters.meters;
  }

  @override
  List<TransportType> calculateTransportTypes() {
    return [this.transportType];
  }

  @override
  TransportType calculateMostUsedType() {
    return this.transportType;
  }

  @override
  List<Leg> getLegs() {
    return [this];
  }

  @override
  bool deepEquals(PositionCollection other) {
    if (other is Leg) {
      return this.transportType == other.transportType &&
          this.trackedPoints.length == other.trackedPoints.length &&
          this.trackedPoints.every((element) => other.trackedPoints.contains(element));
    }
    return false;
  }

  Map<String, dynamic> toJson() => _$LegToJson(this);
}
