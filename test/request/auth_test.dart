import 'package:app_backend/controller/request/bodies/request/auth_request.dart';
import 'package:app_backend/controller/request/bodies/response/auth_response.dart';
import 'package:app_backend/controller/request/request_exception.dart';
import 'package:app_backend/controller/request/trekko_server.dart';
import 'package:app_backend/controller/request/url_trekko_server.dart';
import 'package:test/test.dart';

void main() {
  AuthRequest authRequest = AuthRequest("realAccount@web.de", "1aA!hklj32r4hkjl324r");
  late TrekkoServer server;
  setUp(() {
    server = UrlTrekkoServer("http://localhost:8080");
  });

  test("Signing in with a non existing account", () async {
    try {
      await server.signIn(AuthRequest("notExisting", "test"));
      fail("Expected exception");
    } catch (e) {
      expect(e, isA<RequestException>());
    }
  });

  test("Registering and signing in", () async {
    try {
      AuthResponse response = await server.signUp(authRequest);
      expect(response, isA<AuthResponse>());
      expect(response.token, isNotNull);
    } catch (e) {
      expect(e, isA<RequestException>());
    }

    AuthResponse response = await server.signIn(authRequest);
    expect(response, isA<AuthResponse>());
    expect(response.token, isNotNull);
  });
}
