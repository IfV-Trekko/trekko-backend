import 'package:trekko_backend/model/trip/trip.dart';
import 'package:fling_units/fling_units.dart';
import 'package:json_annotation/json_annotation.dart';

part 'server_trip.g.dart';

@JsonSerializable()
class ServerTrip {
  @JsonKey(name: "uid")
  final String uid;
  @JsonKey(name: "startTimestamp")
  final int startTimestamp;
  @JsonKey(name: "endTimestamp")
  final int endTimestamp;
  @JsonKey(name: "distance")
  final double distance;
  @JsonKey(name: "transportTypes")
  final List<String> transportTypes;
  @JsonKey(name: "purpose")
  final String? purpose;
  @JsonKey(name: "comment")
  final String? comment;

  ServerTrip(this.uid, this.startTimestamp, this.endTimestamp, this.distance,
      this.transportTypes, this.purpose, this.comment);

  ServerTrip.fromTrip(Trip trip)
      : uid = trip.id.toString(),
        startTimestamp = trip.calculateStartTime().millisecondsSinceEpoch,
        endTimestamp = trip.calculateEndTime().millisecondsSinceEpoch,
        distance = trip.calculateDistance().as(meters),
        transportTypes =
            trip.calculateTransportTypes().map((e) => e.name).toList(),
        purpose = trip.purpose,
        comment = trip.comment;

  dynamic toJson() => _$ServerTripToJson(this);

  factory ServerTrip.fromJson(dynamic json) => _$ServerTripFromJson(json);
}
