import 'package:trekko_backend/controller/request/bodies/request/code_request.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CodeRequest Tests', () {
    // Test für die toJson Methode
    test('CodeRequest toJson', () {
      final codeRequest = CodeRequest('123456');
      final json = codeRequest.toJson();

      expect(json, isA<Map<String, dynamic>>());
      expect(json['code'], '123456');
    });

    // Test für die fromJson Methode
    test('CodeRequest fromJson', () {
      final json = {'code': '123456'};
      final codeRequest = CodeRequest.fromJson(json);

      expect(codeRequest, isA<CodeRequest>());
      expect(codeRequest.code, '123456');
    });
  });
}
