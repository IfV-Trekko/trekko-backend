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
import 'package:app_backend/controller/request/bodies/response/trips_response.dart';
import 'package:app_backend/controller/request/bodies/server_profile.dart';
import 'package:app_backend/controller/request/bodies/server_trip.dart';
import 'package:app_backend/controller/request/endpoint.dart';
import 'package:app_backend/controller/request/request_exception.dart';
import 'package:app_backend/controller/request/trekko_server.dart';
import 'package:http/http.dart';
import 'package:requests/requests.dart';

class UrlTrekkoServer implements TrekkoServer {
  final String baseUrl;
  final String? token;

  UrlTrekkoServer(this.baseUrl) : this.token = null;

  UrlTrekkoServer.withToken(this.baseUrl, this.token);

  _parseUrl<S, R>(Endpoint endpoint) {
    return baseUrl + endpoint.path;
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

  T _parseBody<T>(Response response, int expectedStatusCode,
      T Function(Map<String, dynamic>) parser) {
    if (response.statusCode != expectedStatusCode) {
      var decoded;
      try {
        decoded = jsonDecode(response.body);
      } catch (e) {
        throw RequestException(response.statusCode, null);
      }
      throw RequestException(
          response.statusCode, ErrorResponse.fromJson(decoded));
    }

    return parser.call(jsonDecode(response.body));
  }

  Future<T> _sendRequest<T>(
      Future<Response> Function(String,
              {dynamic body,
              RequestBodyEncoding bodyEncoding,
              Map<String, String>? headers,
              dynamic json,
              bool persistCookies,
              int? port,
              Map<String, dynamic>? queryParameters,
              int timeoutSeconds,
              bool verify,
              bool withCredentials})
          requestCall,
      Endpoint endpoint,
      dynamic encode,
      int expectedStatusCode,
      T Function(Map<String, dynamic>) parser) {
    return requestCall(_parseUrl(endpoint),
            headers: _buildHeader(endpoint), body: encode.toJson())
        .then((value) => _parseBody(value, expectedStatusCode, parser));
  }

  @override
  Future<AuthResponse> signIn(AuthRequest request) {
    return _sendRequest(
      Requests.post,
      Endpoint.signIn,
      request,
      200,
      AuthResponse.fromJson,
    );
  }

  @override
  Future<AuthResponse> signUp(AuthRequest request) {
    return _sendRequest(
      Requests.post,
      Endpoint.signUp,
      request,
      201,
      AuthResponse.fromJson,
    );
  }

  @override
  Future<EmptyResponse> sendCode(SendCodeRequest request) {
    return _sendRequest(
      Requests.post,
      Endpoint.forgot_password,
      request,
      200,
      EmptyResponse.fromJson,
    );
  }

  @override
  Future<EmptyResponse> confirmEmail(CodeRequest request) {
    return _sendRequest(
      Requests.post,
      Endpoint.emailConfirm,
      request,
      200,
      EmptyResponse.fromJson,
    );
  }

  @override
  Future<EmptyResponse> changePassword(ChangePasswordRequest request) {
    return _sendRequest(
      Requests.post,
      Endpoint.forgot_password,
      request,
      200,
      EmptyResponse.fromJson,
    );
  }

  @override
  Future<TripsResponse> donateTrips(TripsRequest request) {
    return _sendRequest(
      Requests.post,
      Endpoint.donate,
      request,
      201,
      TripsResponse.fromJson,
    );
  }

  @override
  Future<ServerTrip> updateTrip(ServerTrip trip) {
    return _sendRequest(
      Requests.put,
      Endpoint.trip, // TODO: Replace tripId in endpoint
      trip,
      200,
      ServerTrip.fromJson,
    );
  }

  @override
  Future<EmptyResponse> deleteTrip(String tripId) {
    return _sendRequest(
      Requests.delete,
      Endpoint.trip, // TODO: Replace tripId in endpoint
      EmptyRequest(),
      204,
      EmptyResponse.fromJson,
    );
  }

  @override
  Future<ServerProfile> getProfile() {
    return _sendRequest(
      Requests.get,
      Endpoint.profile,
      EmptyRequest(),
      200,
      ServerProfile.fromJson,
    );
  }

  @override
  Future<EmptyResponse> updateProfile(ServerProfile profile) {
    return _sendRequest(
      Requests.put,
      Endpoint.profile,
      profile,
      200,
      EmptyResponse.fromJson,
    );
  }

  @override
  Future<EmptyResponse> deleteAccount() {
    return _sendRequest(
      Requests.delete,
      Endpoint.profile,
      EmptyRequest(),
      204,
      EmptyResponse.fromJson,
    );
  }

  @override
  Future<FormResponse> getForm() {
    return _sendRequest(
      Requests.get,
      Endpoint.form,
      EmptyRequest(),
      200,
      FormResponse.fromJson,
    );
  }
}
