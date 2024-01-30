import 'package:app_backend/controller/request/bodies/response/error_response.dart';

class RequestException implements Exception {
  final int code;
  final ErrorResponse? reason;

  RequestException(this.code, this.reason);

  @override
  String toString() {
    return "RequestException: $code, $reason";
  }
}
