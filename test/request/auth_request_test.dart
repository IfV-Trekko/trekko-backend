import 'package:trekko_backend/controller/request/bodies/response/auth_response.dart';
import 'package:test/test.dart';
import 'package:trekko_backend/controller/request/bodies/request/auth_request.dart';

void main() {
  group('AuthRequest Tests', () {
    test('Serialisierung und Deserialisierung', () {
      // Erstelle ein Beispiel AuthRequest Objekt
      final authRequest = AuthRequest('test@example.com', 'password123');

      // Serialisiere das AuthRequest Objekt zu JSON
      final json = authRequest.toJson();

      // Überprüfe, ob die Serialisierung korrekt funktioniert
      expect(json, isA<Map<String, dynamic>>());
      expect(json['email'], 'test@example.com');
      expect(json['password'], 'password123');

      // Deserialisiere das JSON-Objekt zurück zu einem AuthRequest Objekt
      final deserializedAuthRequest = AuthRequest.fromJson(json);

      // Überprüfe, ob die Deserialisierung korrekt funktioniert
      expect(deserializedAuthRequest, isA<AuthRequest>());
      expect(deserializedAuthRequest.email, 'test@example.com');
      expect(deserializedAuthRequest.password, 'password123');
    });
  });

  // Grouping tests related to AuthResponse
  group('AuthResponse', () {
    // Test to check if fromJson returns AuthResponse when valid json is provided
    test('fromJson should return AuthResponse when valid json is provided', () {
      final json = {"token": "validToken"};
      final result = AuthResponse.fromJson(json);
      expect(result, isA<AuthResponse>());
      expect(result.token, equals("validToken"));
    });

    // Test to check if fromJson throws an error when invalid json is provided
    test('fromJson should throw when invalid json is provided', () {
      final json = {"invalidKey": "invalidValue"};
      expect(() => AuthResponse.fromJson(json), throwsA(isA<TypeError>()));
    });

    // Test to check if toJson returns valid json from AuthResponse
    test('toJson should return valid json from AuthResponse', () {
      final authResponse = AuthResponse("validToken");
      final result = authResponse.toJson();
      expect(result, equals({"token": "validToken"}));
    });
  });
}
