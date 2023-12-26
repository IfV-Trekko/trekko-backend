import 'package:app_backend/controller/request/trekko_request.dart';
import 'package:http/http.dart';
import 'package:requests/requests.dart';

class TrekkoServer {
  final String baseUrl;
  String? token;

  TrekkoServer(this.baseUrl);

  TrekkoServer.withToken(this.baseUrl, this.token);

  parseUrl<S, R>(TrekkoRequest<S, R> request) {
    return baseUrl + request.endpoint.path;
  }

  Map<String, String> buildHeader(TrekkoRequest request) {
    Map<String, String> header = {};
    header["Content-Type"] = "application/json";

    if (request.endpoint.needsAuth) {
      if (token == null) {
        throw Exception("No authorization token provided");
      }

      header["Authorization"] = "Bearer $token";
    }

    return header;
  }

  Future<R> sendRequest<T, R>(
      Future<Response> Function(
              String, Map<String, String> headers, String body)
          requestCall,
      TrekkoRequest<T, R> request) {
    return requestCall(
            parseUrl(request), buildHeader(request), parseRequest(request))
        .then((value) => parseResponse(request, value));
  }

  Future<R> post<T, R>(TrekkoRequest<T, R> request) {
    return sendRequest(
        (url, header, body) => Requests.post(url, headers: header, body: body),
        request);
  }

  Future<R> get<T, R>(TrekkoRequest<T, R> request) {
    return sendRequest(
        (url, header, body) => Requests.get(url, headers: header, body: body),
        request);
  }

  Future<R> put<T, R>(TrekkoRequest<T, R> request) {
    return sendRequest(
        (url, header, body) => Requests.put(url, headers: header, body: body),
        request);
  }

  Future<R> delete<T, R>(TrekkoRequest<T, R> request) {
    return sendRequest(
        (url, header, body) => Requests.delete(url, headers: header, body: body),
        request);
  }

  static R parseResponse<S, R>(TrekkoRequest<S, R> request, Response response) {
    if (request.expectedStatusCode != request.expectedStatusCode) {
      // TODO: throw a proper exception
      throw Exception("Wrong status code ${request.expectedStatusCode}");
    }

    return request.endpoint.responseParser(response.body);
  }

  static String parseRequest<S, R>(TrekkoRequest<S, R> request) {
    return request.endpoint.requestParser(request.body);
  }
}
