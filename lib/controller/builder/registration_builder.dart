import 'package:trekko_backend/controller/builder/auth_builder.dart';
import 'package:trekko_backend/controller/builder/build_exception.dart';
import 'package:trekko_backend/controller/builder/registration_result.dart';
import 'package:trekko_backend/controller/request/bodies/request/auth_request.dart';
import 'package:trekko_backend/controller/request/bodies/response/auth_response.dart';
import 'package:trekko_backend/controller/request/trekko_server.dart';
import 'package:trekko_backend/controller/request/url_trekko_server.dart';
import 'package:trekko_backend/controller/trekko.dart';

class RegistrationBuilder extends AuthBuilder {
  String? password;
  String? passwordConfirmation;
  String? code;

  RegistrationBuilder.withData(
      {String? projectUrl,
      String? email,
      this.password,
      this.passwordConfirmation,
      this.code})
      : super.withData(projectUrl: projectUrl, email: email);

  @override
  Map<int, Object> getErrorCodes() {
    return RegistrationResult.map;
  }

  @override
  Future<Trekko> build() {
    if (password != passwordConfirmation) {
      throw BuildException(null, RegistrationResult.failedPasswordRepeat);
    }

    if (code!.isEmpty) {
      throw BuildException(null, RegistrationResult.failedBadCode);
    }

    TrekkoServer server = UrlTrekkoServer(projectUrl!);
    return server
        .signUp(AuthRequest(email!, password!))
        .catchError(onError<AuthResponse>)
        .then((value) async {
      // await _server.confirmEmail(CodeRequest(_code));
      return makeTrekko(projectUrl!, email!, value.token);
    });
  }
}
