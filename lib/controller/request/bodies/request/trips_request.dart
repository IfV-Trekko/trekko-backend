import 'package:trekko_backend/controller/request/bodies/server_trip.dart';
import 'package:trekko_backend/model/trip/trip.dart';

class TripsRequest {
  late final List<ServerTrip> trips;

  TripsRequest(this.trips);

  TripsRequest.fromTrips(List<Trip> trips) {
    this.trips = trips.map((trip) => ServerTrip.fromTrip(trip)).toList();
  }

  dynamic toJson() => trips.map((e) => e.toJson()).toList();

  factory TripsRequest.fromJson(dynamic json) {
    return TripsRequest(
        (json as List<dynamic>).map((e) => ServerTrip.fromJson(e)).toList());
  }
}
