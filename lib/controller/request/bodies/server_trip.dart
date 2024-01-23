import 'package:app_backend/controller/utils/position_utils.dart';
import 'package:app_backend/model/trip/trip.dart';
import 'package:json_annotation/json_annotation.dart';

part 'server_trip.g.dart';

@JsonSerializable()
class ServerTrip {
  final String uid;
  final int startTimestamp;
  final int endTimestamp;
  final double distance;
  final List<String> transportTypes;
  final String? purpose;
  final String? comment;

  ServerTrip(this.uid, this.startTimestamp, this.endTimestamp, this.distance,
      this.transportTypes, this.purpose, this.comment);

  ServerTrip.fromTrip(Trip trip)
      : uid = trip.id.toString(),
        startTimestamp = trip.startTime.millisecondsSinceEpoch,
        endTimestamp = trip.endTime.millisecondsSinceEpoch,
        distance = PositionUtils.distanceBetweenPoints(trip.legs
            .expand((e) => e.trackedPoints)
            .map((e) => e.toPosition())
            .toList()),
        transportTypes =
            trip.legs.map((e) => e.transportType.toString()).toList(),
        purpose = trip.purpose,
        comment = trip.comment;

  Map<String, dynamic> toJson() => _$ServerTripToJson(this);

  factory ServerTrip.fromJson(Map<String, dynamic> json) =>
      _$ServerTripFromJson(json);
}
