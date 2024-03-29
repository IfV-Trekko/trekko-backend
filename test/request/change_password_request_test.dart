import 'package:trekko_backend/controller/request/bodies/request/change_password_request.dart';
import 'package:flutter_test/flutter_test.dart';


void main() {
  group('ChangePasswordRequest Tests', () {
    // Test für die toJson Methode
    test('ChangePasswordRequest toJson', () {
      final request = ChangePasswordRequest(
          'test@example.com',
          'newPassword123',
          'verificationCode123'
      );

      final jsonMap = request.toJson();

      expect(jsonMap, isA<Map<String, dynamic>>());
      expect(jsonMap['email'], 'test@example.com');
      expect(jsonMap['newPassword'], 'newPassword123');
      expect(jsonMap['code'], 'verificationCode123');
    });

    // Test für die fromJson Methode
    test('ChangePasswordRequest fromJson', () {
      final jsonMap = {
        'email': 'test@example.com',
        'newPassword': 'newPassword123',
        'code': 'verificationCode123'
      };

      final request = ChangePasswordRequest.fromJson(jsonMap);

      expect(request, isA<ChangePasswordRequest>());
      expect(request.email, 'test@example.com');
      expect(request.newPassword, 'newPassword123');
      expect(request.code, 'verificationCode123');
    });
  });
}
