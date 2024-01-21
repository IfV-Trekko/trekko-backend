import 'package:app_backend/controller/builder/build_exception.dart';
import 'package:app_backend/controller/builder/registration_result.dart';
import 'package:app_backend/controller/builder/trekko_builder.dart';
import 'package:app_backend/controller/request/bodies/request/auth_request.dart';
import 'package:app_backend/controller/request/bodies/request/code_request.dart';
import 'package:app_backend/controller/request/bodies/response/auth_response.dart';
import 'package:app_backend/controller/request/trekko_server.dart';
import 'package:app_backend/controller/request/url_trekko_server.dart';
import 'package:app_backend/controller/trekko.dart';

class RegistrationBuilder extends TrekkoBuilder {
  final String _projectUrl;
  final String _email;
  final String _password;
  final String _passwordConfirmation;
  final String _code;
  late final TrekkoServer _server;

  RegistrationBuilder(this._projectUrl, this._email, this._password,
      this._passwordConfirmation, this._code) {
    _server = UrlTrekkoServer(_projectUrl);
  }

  @override
  Map<int, Object> getErrorCodes() {
    return RegistrationResult.map;
  }

  @override
  Future<Trekko> build() {
    if (_password != _passwordConfirmation) {
      throw BuildException(null, RegistrationResult.failedPasswordRepeat);
    }

    if (_code.isEmpty) {
      throw BuildException(null, RegistrationResult.failedBadCode);
    }

    return _server
        .signUp(AuthRequest(_email, _password))
        .catchError(onError<AuthResponse>)
        .then((value) async {
      await _server.confirmEmail(CodeRequest(_code));
      return makeTrekko(_projectUrl, _email, value.token);
    });
  }
}
