import 'package:trekko_backend/controller/request/bodies/request/auth_request.dart';
import 'package:trekko_backend/controller/request/bodies/request/change_password_request.dart';
import 'package:trekko_backend/controller/request/bodies/request/code_request.dart';
import 'package:trekko_backend/controller/request/bodies/request/send_code_request.dart';
import 'package:trekko_backend/controller/request/bodies/request/trips_request.dart';
import 'package:trekko_backend/controller/request/bodies/response/auth_response.dart';
import 'package:trekko_backend/controller/request/bodies/response/empty_response.dart';
import 'package:trekko_backend/controller/request/bodies/response/form_response.dart';
import 'package:trekko_backend/controller/request/bodies/response/onboarding_text_response.dart';
import 'package:trekko_backend/controller/request/bodies/response/project_metadata_response.dart';
import 'package:trekko_backend/controller/request/bodies/response/trips_response.dart';
import 'package:trekko_backend/controller/request/bodies/server_profile.dart';
import 'package:trekko_backend/controller/request/bodies/server_trip.dart';
import 'package:trekko_backend/controller/request/bodies/server_user.dart';
import 'package:trekko_backend/controller/request/endpoint.dart';

abstract class TrekkoServer {
  Future<void> init();

  Future<void> close();

  Future<AuthResponse> signIn(AuthRequest request);

  Future<AuthResponse> signUp(AuthRequest request);

  Future<EmptyResponse> sendCode(SendCodeRequest request);

  Future<EmptyResponse> confirmEmail(CodeRequest request);

  Future<EmptyResponse> changePassword(ChangePasswordRequest request);

  Future<OnboardingTextResponse> getOnboardingText(Endpoint endpoint);

  Future<ProjectMetadataResponse> getProjectMetadata();

  Future<ServerUser> getUser();

  Future<TripsResponse> donateTrips(TripsRequest request);

  Future<ServerTrip> updateTrip(ServerTrip trip);

  Future<EmptyResponse> deleteTrip(String tripId);

  Future<ServerProfile> getProfile();

  Future<EmptyResponse> createProfile(ServerProfile profile);

  Future<EmptyResponse> updateProfile(ServerProfile profile);

  Future<EmptyResponse> deleteAccount();

  Future<FormResponse> getForm();
}
