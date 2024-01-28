import 'package:app_backend/controller/request/bodies/request/send_code_request.dart';
import 'package:app_backend/controller/request/trekko_server.dart';
import 'package:app_backend/controller/request/url_trekko_server.dart';
import 'package:app_backend/controller/utils/database_utils.dart';
import 'package:app_backend/model/profile/profile.dart';
import 'package:isar/isar.dart';

class AuthentificationUtils {
  static Future<void> sendCode(String projectUrl, String email) {
    return UrlTrekkoServer(projectUrl).sendCode(SendCodeRequest(email));
  }

  static Future<bool> deleteProfile(String projectUrl, String email) async {
    Isar db = await DatabaseUtils.establishConnection([ProfileSchema]);
    Profile? profile = await db.profiles
        .filter()
        .projectUrlEqualTo(projectUrl)
        .and()
        .emailEqualTo(email)
        .findFirst();
    if (profile == null) {
      return false;
    }

    TrekkoServer server = UrlTrekkoServer.withToken(projectUrl, profile.token);
    return await server.deleteAccount().then((value) async {
      return await db
          .writeTxn(() async => await db.profiles.delete(profile.id));
    });
  }
}
