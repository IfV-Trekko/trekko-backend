import 'package:app_backend/controller/builder/registration_result.dart';
import 'package:app_backend/controller/builder/trekko_builder.dart';
import 'package:app_backend/controller/request/bodies/request/auth_request.dart';
import 'package:app_backend/controller/request/bodies/response/auth_response.dart';
import 'package:app_backend/controller/request/trekko_server.dart';
import 'package:app_backend/controller/trekko.dart';
import 'package:app_backend/controller/linked_trekko.dart';
import 'package:app_backend/model/account/account_data.dart';

class RegistrationBuilder extends TrekkoBuilder {

  final String projectUrl;
  final String email;
  final String password;
  final String passwordConfirmation;
  final String code;
  late final TrekkoServer server;

  RegistrationBuilder(this.projectUrl, this.email, this.password, this.passwordConfirmation, this.code) {
    server = TrekkoServer(projectUrl);
  }

  @override
  Map<int, Object> getErrorCodes() {
    return RegistrationResult.values.asMap();
  }

  @override
  Future<Trekko> build() {
    return server
        .signUp(AuthRequest(email, password))
        .catchError(onError<AuthResponse>)
        .then((value) => LinkedTrekko(AccountData(projectUrl, email, value.token)));
  }
}