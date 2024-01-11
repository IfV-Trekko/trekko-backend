import 'dart:convert';

import 'package:app_backend/controller/request/bodies/request/auth_request.dart';
import 'package:app_backend/controller/request/bodies/request/code_request.dart';
import 'package:app_backend/controller/request/bodies/request/trips_request.dart';
import 'package:app_backend/controller/request/bodies/response/auth_response.dart';
import 'package:app_backend/controller/request/bodies/response/empty_response.dart';
import 'package:app_backend/controller/request/bodies/response/error_response.dart';
import 'package:app_backend/controller/request/bodies/response/trips_response.dart';
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
  Future<EmptyResponse> deleteTrip(String tripId) {
    // TODO: implement deleteTrip
    throw UnimplementedError();
  }

  @override
  Future<TripsResponse> donateTrips(TripsRequest request) {
    // TODO: implement donateTrips
    throw UnimplementedError();
  }
}
