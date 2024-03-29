import 'package:trekko_backend/controller/builder/build_exception.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('BuildException Tests', () {
    test('should correctly initialize with cause and reason', () {
      final exceptionCause = Exception('Test cause');
      final exceptionReason = 'Test reason';

      final exception = BuildException(exceptionCause, exceptionReason);

      expect(exception.cause, equals(exceptionCause));
      expect(exception.reason, equals(exceptionReason));
    });

    test('toString should return the correct format', () {
      final exceptionCause = Exception('Test cause');
      final exceptionReason = 'Test reason';

      final exception = BuildException(exceptionCause, exceptionReason);

      expect(exception.toString(), equals('BuildException: Test reason, Exception: Test cause'));
    });

    test('should handle null cause gracefully', () {
      final exceptionReason = 'Test reason without cause';

      final exception = BuildException(null, exceptionReason);

      expect(exception.cause, isNull);
      expect(exception.reason, equals(exceptionReason));
      expect(exception.toString(), equals('BuildException: Test reason without cause, null'));
    });
  });
}