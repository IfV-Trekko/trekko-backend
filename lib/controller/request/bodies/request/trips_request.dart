import 'package:app_backend/controller/request/bodies/server_trip.dart';
import 'package:app_backend/model/trip/trip.dart';

class TripsRequest {

  late final List<ServerTrip> trips;

  TripsRequest(this.trips);

  TripsRequest.fromTrips(List<Trip> trips) {
    this.trips = trips.map((trip) => ServerTrip.fromTrip(trip)).toList();
  }

}