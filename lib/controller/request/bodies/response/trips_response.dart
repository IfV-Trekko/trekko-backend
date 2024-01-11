import 'package:app_backend/controller/request/bodies/server_trip.dart';
import 'package:app_backend/model/trip/trip.dart';

class TripsResponse {

  late final List<ServerTrip> trips;

  TripsResponse(this.trips);

  TripsResponse.fromTrips(List<Trip> trips) {
    this.trips = trips.map((trip) => ServerTrip.fromTrip(trip)).toList();
  }
}