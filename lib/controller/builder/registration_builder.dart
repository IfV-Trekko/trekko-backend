import 'package:isar/isar.dart';
import 'package:trekko_backend/controller/builder/auth_builder.dart';
import 'package:trekko_backend/controller/builder/build_exception.dart';
import 'package:trekko_backend/controller/builder/registration_result.dart';
import 'package:trekko_backend/controller/request/bodies/request/auth_request.dart';
import 'package:trekko_backend/controller/request/bodies/response/auth_response.dart';
import 'package:trekko_backend/controller/request/trekko_server.dart';
import 'package:trekko_backend/controller/request/url_trekko_server.dart';
import 'package:trekko_backend/controller/trekko.dart';
import 'package:trekko_backend/controller/utils/database_utils.dart';
import 'package:trekko_backend/model/profile/preferences.dart';
import 'package:trekko_backend/model/profile/profile.dart';

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

  Future<Profile> _createProfile(String token) async {
    Profile newProfile = Profile(
        projectUrl: projectUrl!,
        email: email!,
        token: token,
        lastLogin: DateTime.now(),
        preferences: Preferences());
    Isar profileDb = await Databases.profile.getInstance();
    await profileDb.writeTxn(() async {
      newProfile.id = await profileDb.profiles.put(newProfile);
    });
    return newProfile;
  }

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
      return makeTrekko(await _createProfile(value.token));
    });
  }
}
