import 'package:test/test.dart';
import 'package:app_backend/controller/request/bodies/request/auth_request.dart';

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
}
