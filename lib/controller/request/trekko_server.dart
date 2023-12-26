import 'dart:convert';

import 'package:app_backend/controller/request/bodies/request/auth_request.dart';
import 'package:app_backend/controller/request/bodies/response/auth_response.dart';
import 'package:app_backend/controller/request/bodies/response/error_response.dart';
import 'package:app_backend/controller/request/endpoint.dart';
import 'package:app_backend/controller/request/request_exception.dart';
import 'package:http/http.dart';
import 'package:requests/requests.dart';

class TrekkoServer {
  final String baseUrl;
  String? token;

  TrekkoServer(this.baseUrl);

  TrekkoServer.withToken(this.baseUrl, this.token);

  parseUrl<S, R>(Endpoint endpoint) {
    return baseUrl + endpoint.path;
  }

  Map<String, String> buildHeader(Endpoint endpoint) {
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

  T parseBody<T>(Response response, int expectedStatusCode,
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

  Future<T> sendRequest<T>(
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
    return requestCall(parseUrl(endpoint),
            headers: buildHeader(endpoint), body: encode.toJson())
        .then((value) => parseBody(value, expectedStatusCode, parser));
  }

  Future<AuthResponse> signIn(AuthRequest request) {
    return sendRequest(
      Requests.post,
      Endpoint.signIn,
      request,
      200,
      AuthResponse.fromJson,
    );
  }

  Future<AuthResponse> signUp(AuthRequest request) {
    return sendRequest(
      Requests.post,
      Endpoint.signUp,
      request,
      201,
      AuthResponse.fromJson,
    );
  }
}
