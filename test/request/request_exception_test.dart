import 'package:trekko_backend/controller/request/bodies/response/error_response.dart';
import 'package:trekko_backend/controller/request/request_exception.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('RequestException Tests', () {
    test('should correctly initialize with code and reason', () {
      final errorCode = 404;
      final errorReason = ErrorResponse(100, 'Not Found');

      final exception = RequestException(errorCode, errorReason);

      expect(exception.code, equals(errorCode));
      expect(exception.reason, equals(errorReason));
    });

    test('toString should return the correct format', () {
      final errorCode = 500;
      final errorReason = ErrorResponse(100, 'Internal Server Error');

      final exception = RequestException(errorCode, errorReason);

      expect(
          exception.toString(),
          equals(
              'RequestException: 500, ErrorResponse{reasonCode: 100, message: Internal Server Error}'));
    });

    test('should handle null reason gracefully', () {
      final errorCode = 401;

      final exception = RequestException(errorCode, null);

      expect(exception.code, equals(errorCode));
      expect(exception.reason, isNull);
      expect(exception.toString(), equals('RequestException: 401, null'));
    });
  });
}
