import 'package:app_backend/controller/request/bodies/request/auth_request.dart';
import 'package:app_backend/controller/request/trekko_server.dart';
import 'package:app_backend/controller/request/url_trekko_server.dart';

class RequestUtils {
  static const String password = "1aA!hklj32r4hkjl324r";
  static const String address = "http://localhost:8080";

  static Future<TrekkoServer> loginOrRegister(String email) {
    AuthRequest request = AuthRequest(email, password);
    TrekkoServer server = UrlTrekkoServer(address);
    return server
        .signIn(request)
        .onError((error, stackTrace) async => server.signUp(request))
        .then((value) => UrlTrekkoServer.withToken(address, value.token));
  }
}
