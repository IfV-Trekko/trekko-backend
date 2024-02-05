import 'package:app_backend/controller/builder/auth_builder.dart';
import 'package:app_backend/controller/builder/login_result.dart';
import 'package:app_backend/controller/request/bodies/request/auth_request.dart';
import 'package:app_backend/controller/request/bodies/response/auth_response.dart';
import 'package:app_backend/controller/request/trekko_server.dart';
import 'package:app_backend/controller/request/url_trekko_server.dart';
import 'package:app_backend/controller/trekko.dart';

class LoginBuilder extends AuthBuilder {
  String? password;

  LoginBuilder();

  LoginBuilder.withData({String? projectUrl, String? email, this.password})
      : super.withData(projectUrl: projectUrl, email: email);

  @override
  Map<int, Object> getErrorCodes() {
    return LoginResult.map;
  }

  @override
  Future<Trekko> build() {
    TrekkoServer server = UrlTrekkoServer(projectUrl!);
    return server
        .signIn(AuthRequest(email!, password!))
        .catchError(onError<AuthResponse>)
        .then((value) => makeTrekko(projectUrl!, email!, value.token));
  }
}
