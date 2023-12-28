import 'package:app_backend/controller/builder/login_result.dart';
import 'package:app_backend/controller/builder/trekko_builder.dart';
import 'package:app_backend/controller/request/bodies/request/auth_request.dart';
import 'package:app_backend/controller/request/bodies/response/auth_response.dart';
import 'package:app_backend/controller/request/trekko_server.dart';
import 'package:app_backend/controller/trekko.dart';
import 'package:app_backend/controller/profile_trekko.dart';
import 'package:app_backend/model/account/profile.dart';
import 'package:app_backend/model/account/preferences.dart';

class LoginBuilder extends TrekkoBuilder {
  final String projectUrl;
  final String email;
  final String password;
  late final TrekkoServer server;

  LoginBuilder(this.projectUrl, this.email, this.password) {
    server = TrekkoServer(projectUrl);
  }

  @override
  Map<int, Object> getErrorCodes() {
    return LoginResult.values.asMap(); // TODO: Don't use order
  }

  @override
  Future<Trekko> build() {
    return server
        .signIn(AuthRequest(email, password))
        .catchError(onError<AuthResponse>)
        .then((value) => ProfiledTrekko(Profile(projectUrl, email, value.token, Preferences())));
  }
}
