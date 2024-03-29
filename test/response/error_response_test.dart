import 'package:trekko_backend/controller/request/bodies/response/error_response.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ErrorResponse', () {
    test('fromJson should return correct ErrorResponse when valid json is provided', () {
      final json = {
        "reasonCode": 404,
        "reason": "Not Found"
      };

      final result = ErrorResponse.fromJson(json);

      expect(result.reasonCode, 404);
      expect(result.message, "Not Found");
    });

    test('fromJson should throw exception when invalid json is provided', () {
      final json = {
        "invalidKey": "value"
      };

      expect(() => ErrorResponse.fromJson(json), throwsA(isInstanceOf<TypeError>()));
    });

    test('toJson should return correct json representation of ErrorResponse', () {
      final errorResponse = ErrorResponse(404, "Not Found");

      final result = errorResponse.toJson();

      expect(result, {
        "reasonCode": 404,
        "reason": "Not Found"
      });
    });

    test('toString should return correct string representation of ErrorResponse', () {
      final errorResponse = ErrorResponse(404, "Not Found");

      final result = errorResponse.toString();

      expect(result, "ErrorResponse{reasonCode: 404, message: Not Found}");
    });
  });
}