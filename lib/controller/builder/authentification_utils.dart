import 'package:app_backend/controller/request/bodies/request/send_code_request.dart';
import 'package:app_backend/controller/request/url_trekko_server.dart';
import 'package:app_backend/controller/utils/database_utils.dart';
import 'package:app_backend/model/profile/profile.dart';
import 'package:isar/isar.dart';

class AuthentificationUtils {
  static Future<void> sendCode(String projectUrl, String email) {
    return UrlTrekkoServer(projectUrl).sendCode(SendCodeRequest(email));
  }

  static Future<bool> deleteProfile(String projectUrl, String email) async {
    Isar db = await DatabaseUtils.establishConnection();
    // TODO: Also delete from server?
    return await db.writeTxn(() async {
      return await db.profiles
          .filter()
          .projectUrlEqualTo(projectUrl)
          .and()
          .emailEqualTo(email)
          .deleteFirst();
    });
  }
}