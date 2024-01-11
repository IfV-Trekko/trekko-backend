import 'package:app_backend/controller/request/bodies/request/auth_request.dart';
import 'package:app_backend/controller/request/bodies/request/code_request.dart';
import 'package:app_backend/controller/request/bodies/request/trips_request.dart';
import 'package:app_backend/controller/request/bodies/response/auth_response.dart';
import 'package:app_backend/controller/request/bodies/response/empty_response.dart';
import 'package:app_backend/controller/request/bodies/response/trips_response.dart';

abstract class TrekkoServer {

  Future<AuthResponse> signIn(AuthRequest request);

  Future<AuthResponse> signUp(AuthRequest request);

  Future<EmptyResponse> confirmEmail(CodeRequest request);

  Future<TripsResponse> donateTrips(TripsRequest request);

  Future<EmptyResponse> deleteTrip(String tripId);
}
