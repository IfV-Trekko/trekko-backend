import 'package:app_backend/controller/request/bodies/server_trip.dart';
import 'package:app_backend/model/trip/trip.dart';
import 'package:json_annotation/json_annotation.dart';

class TripsResponse {
  @JsonKey(name: "trips")
  late final List<ServerTrip> trips;

  TripsResponse(this.trips);

  TripsResponse.fromTrips(List<Trip> trips) {
    this.trips = trips.map((trip) => ServerTrip.fromTrip(trip)).toList();
  }

  Map<String, dynamic> toJson() =>
      {'trips': trips.map((trip) => trip.toJson()).toList()};

  factory TripsResponse.fromJson(Map<String, dynamic> json) {
    return TripsResponse((json['trips'] as List<dynamic>)
        .map((trip) => ServerTrip.fromJson(trip))
        .toList());
  }
}
