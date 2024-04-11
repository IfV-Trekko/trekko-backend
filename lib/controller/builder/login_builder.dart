import 'package:isar/isar.dart';
import 'package:trekko_backend/controller/builder/auth_builder.dart';
import 'package:trekko_backend/controller/builder/login_result.dart';
import 'package:trekko_backend/controller/request/bodies/request/auth_request.dart';
import 'package:trekko_backend/controller/request/bodies/response/auth_response.dart';
import 'package:trekko_backend/controller/request/trekko_server.dart';
import 'package:trekko_backend/controller/request/url_trekko_server.dart';
import 'package:trekko_backend/controller/trekko.dart';
import 'package:trekko_backend/controller/utils/database_utils.dart';
import 'package:trekko_backend/model/profile/preferences.dart';
import 'package:trekko_backend/model/profile/profile.dart';

class LoginBuilder extends AuthBuilder {
  String? password;

  LoginBuilder.withData({String? projectUrl, String? email, this.password})
      : super.withData(projectUrl: projectUrl, email: email);

  Future<Profile> loginProfile(TrekkoServer server, String token) async {
    Isar profileDb = await Databases.profile.getInstance();
    var query = profileDb.profiles
        .filter()
        .emailEqualTo(email!)
        .and()
        .projectUrlEqualTo(projectUrl!);

    if (query.isEmptySync()) {
      Profile newProfile = Profile(
          projectUrl: projectUrl!,
          email: email!,
          token: token,
          lastLogin: DateTime.now(),
          preferences: Preferences());
      await profileDb.writeTxn(() async {
        newProfile.id = await profileDb.profiles.put(newProfile);
      });
      return newProfile;
    } else {
      Profile found = query.findFirstSync()!;
      found.token = token;
      await profileDb.writeTxn(() async {
        await profileDb.profiles.put(found);
      });
      return found;
    }
  }

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
        .then((value) async =>
            makeTrekko(await loginProfile(server, value.token)));
  }
}
