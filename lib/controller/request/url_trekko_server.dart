import 'dart:convert';

import 'package:app_backend/controller/request/bodies/request/auth_request.dart';
import 'package:app_backend/controller/request/bodies/request/change_password_request.dart';
import 'package:app_backend/controller/request/bodies/request/code_request.dart';
import 'package:app_backend/controller/request/bodies/request/empty_request.dart';
import 'package:app_backend/controller/request/bodies/request/send_code_request.dart';
import 'package:app_backend/controller/request/bodies/request/trips_request.dart';
import 'package:app_backend/controller/request/bodies/response/auth_response.dart';
import 'package:app_backend/controller/request/bodies/response/empty_response.dart';
import 'package:app_backend/controller/request/bodies/response/error_response.dart';
import 'package:app_backend/controller/request/bodies/response/form_response.dart';
import 'package:app_backend/controller/request/bodies/response/onboarding_text_response.dart';
import 'package:app_backend/controller/request/bodies/response/trips_response.dart';
import 'package:app_backend/controller/request/bodies/server_profile.dart';
import 'package:app_backend/controller/request/bodies/server_trip.dart';
import 'package:app_backend/controller/request/endpoint.dart';
import 'package:app_backend/controller/request/request_exception.dart';
import 'package:app_backend/controller/request/trekko_server.dart';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';
import 'package:http/retry.dart';
import 'package:sprintf/sprintf.dart';

class UrlTrekkoServer implements TrekkoServer {
  final http.Client _client;
  final String baseUrl;
  final String? token;

  UrlTrekkoServer(this.baseUrl)
      : this.token = null,
        _client = RetryClient(http.Client());

  UrlTrekkoServer.withToken(this.baseUrl, this.token)
      : _client = RetryClient(http.Client());

  Uri _parseUrl<S, R>(Endpoint endpoint, List<String> pathParams) {
    return Uri.parse(baseUrl + sprintf(endpoint.path, pathParams));
  }

  Map<String, String> _buildHeader(Endpoint endpoint) {
    Map<String, String> header = {};
    header["Content-Type"] = "application/json";

    if (endpoint.needsAuth) {
      if (token == null) {
        throw Exception("No authorization token provided");
      }

      header["Authorization"] = "Bearer $token";
    }

    return header;
  }

  T _parseBody<T>(
      Response response, int expectedStatusCode, T Function(Object?) parser) {
    if (response.statusCode != expectedStatusCode) {
      var decoded;
      try {
        decoded = jsonDecode(response.body);
      } catch (e) {
        throw RequestException(response.statusCode, null);
      }
      throw RequestException(
          response.statusCode, ErrorResponse.fromJson(decoded));
    } else if (response.body.isEmpty) {
      return EmptyResponse() as T;
    }

    return parser.call(jsonDecode(response.body));
  }

  Future<T> _sendGet<T>(
      Endpoint endpoint, int expectedStatusCode, T Function(Object?) parser,
      {List<String> pathParams = const []}) {
    return _client
        .get(_parseUrl(endpoint, pathParams), headers: _buildHeader(endpoint))
        .then((value) => _parseBody(value, expectedStatusCode, parser));
  }

  Future<T> _sendRequest<T>(
      Future<Response> Function(Uri,
              {Object? body, Encoding? encoding, Map<String, String>? headers})
          requestCall,
      Endpoint endpoint,
      dynamic encode,
      int expectedStatusCode,
      T Function(Object?) parser,
      {List<String> pathParams = const []}) {
    String coded = json.encode(encode.toJson());
    return requestCall(_parseUrl(endpoint, pathParams),
            headers: _buildHeader(endpoint), body: coded)
        .then((value) => _parseBody(value, expectedStatusCode, parser));
  }

  @override
  Future<void> init() {
    return Future.value();
  }

  @override
  Future<void> close() async {
    _client.close();
  }

  @override
  Future<AuthResponse> signIn(AuthRequest request) {
    return _sendRequest(
      _client.post,
      Endpoint.signIn,
      request,
      200,
      AuthResponse.fromJson,
    );
  }

  @override
  Future<AuthResponse> signUp(AuthRequest request) {
    return _sendRequest(
      _client.post,
      Endpoint.signUp,
      request,
      201,
      AuthResponse.fromJson,
    );
  }

  @override
  Future<EmptyResponse> sendCode(SendCodeRequest request) {
    return _sendRequest(
      _client.post,
      Endpoint.forgot_password,
      request,
      200,
      EmptyResponse.fromJson,
    );
  }

  @override
  Future<EmptyResponse> confirmEmail(CodeRequest request) {
    return _sendRequest(
      _client.post,
      Endpoint.emailConfirm,
      request,
      200,
      EmptyResponse.fromJson,
    );
  }

  @override
  Future<OnboardingTextResponse> getOnboardingText(Endpoint endpoint) {
    return _sendGet(
      endpoint,
      200,
      OnboardingTextResponse.fromJson,
    );
  }

  @override
  Future<EmptyResponse> changePassword(ChangePasswordRequest request) {
    return _sendRequest(
      _client.post,
      Endpoint.forgot_password,
      request,
      200,
      EmptyResponse.fromJson,
    );
  }

  @override
  Future<TripsResponse> donateTrips(TripsRequest request) {
    return _sendRequest(
      _client.post,
      Endpoint.donate,
      request,
      201,
      TripsResponse.fromJson,
    );
  }

  @override
  Future<ServerTrip> updateTrip(ServerTrip trip) {
    return _sendRequest(
      _client.put,
      Endpoint.trip,
      trip,
      200,
      ServerTrip.fromJson,
      pathParams: [trip.uid],
    );
  }

  @override
  Future<EmptyResponse> deleteTrip(String tripId) {
    return _sendRequest(
      _client.delete,
      Endpoint.trip,
      EmptyRequest(),
      204,
      EmptyResponse.fromJson,
      pathParams: [tripId],
    );
  }

  @override
  Future<ServerProfile> getProfile() {
    return _sendGet(
      Endpoint.profile,
      200,
      ServerProfile.fromJson,
    );
  }

  @override
  Future<EmptyResponse> createProfile(ServerProfile profile) {
    return _sendRequest(
      _client.post,
      Endpoint.profile,
      profile,
      201,
      EmptyResponse.fromJson,
    );
  }

  @override
  Future<EmptyResponse> updateProfile(ServerProfile profile) {
    return _sendRequest(
      _client.patch,
      Endpoint.profile,
      profile,
      200,
      EmptyResponse.fromJson,
    );
  }

  @override
  Future<EmptyResponse> deleteAccount() {
    return _sendRequest(
      _client.delete,
      Endpoint.account,
      EmptyRequest(),
      204,
      EmptyResponse.fromJson,
    );
  }

  @override
  Future<FormResponse> getForm() {
    return _sendGet(
      Endpoint.form,
      200,
      FormResponse.fromJson,
    );
  }
}
