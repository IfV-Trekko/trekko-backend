import 'package:app_backend/controller/builder/login_result.dart';
import 'package:app_backend/controller/builder/trekko_builder.dart';
import 'package:app_backend/controller/profiled_trekko.dart';
import 'package:app_backend/controller/request/bodies/request/auth_request.dart';
import 'package:app_backend/controller/request/bodies/response/auth_response.dart';
import 'package:app_backend/controller/request/trekko_server.dart';
import 'package:app_backend/controller/request/url_trekko_server.dart';
import 'package:app_backend/controller/trekko.dart';
import 'package:app_backend/model/profile/preferences.dart';
import 'package:app_backend/model/profile/profile.dart';

class LoginBuilder extends TrekkoBuilder {
  final String _projectUrl;
  final String _email;
  final String _password;
  late final TrekkoServer _server;

  LoginBuilder(this._projectUrl, this._email, this._password) {
    _server = UrlTrekkoServer(_projectUrl);
  }

  @override
  Map<int, Object> getErrorCodes() {
    return LoginResult.map;
  }

  @override
  Future<Trekko> build() {
    return _server
        .signIn(AuthRequest(_email, _password))
        .catchError(onError<AuthResponse>)
        .then((value) => ProfiledTrekko(Profile(
            _projectUrl, _email, value.token, DateTime.now(), Preferences())));
  }
}
