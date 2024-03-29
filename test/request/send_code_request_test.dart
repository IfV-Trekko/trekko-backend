import 'package:flutter_test/flutter_test.dart';
import 'package:trekko_backend/controller/request/bodies/request/send_code_request.dart';

void main() {
  group('SendCodeRequest Tests', () {
    const testEmail = 'test@example.com';

    test('SendCodeRequest toJson', () {
      final request = SendCodeRequest(testEmail);
      final jsonMap = request.toJson();

      expect(jsonMap, isA<Map<String, dynamic>>());
      expect(jsonMap['email'], testEmail);
    });

    test('SendCodeRequest fromJson', () {
      final jsonMap = {'email': testEmail};
      final request = SendCodeRequest.fromJson(jsonMap);

      expect(request, isA<SendCodeRequest>());
      expect(request.email, testEmail);
    });
  });
}
