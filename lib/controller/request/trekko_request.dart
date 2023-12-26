import 'endpoint.dart';

class TrekkoRequest<S, R> {
  final Endpoint<S, R> endpoint;
  final S body;
  final int expectedStatusCode;

  TrekkoRequest(this.endpoint, this.body, this.expectedStatusCode);
}