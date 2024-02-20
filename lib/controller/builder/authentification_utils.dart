import 'package:app_backend/controller/request/bodies/request/send_code_request.dart';
import 'package:app_backend/controller/request/endpoint.dart';
import 'package:app_backend/controller/request/trekko_server.dart';
import 'package:app_backend/controller/request/url_trekko_server.dart';
import 'package:app_backend/controller/utils/database_utils.dart';
import 'package:app_backend/controller/utils/tracking_util.dart';
import 'package:app_backend/model/profile/profile.dart';
import 'package:isar/isar.dart';

class AuthentificationUtils {
  static Future<void> sendCode(String projectUrl, String email) {
    return UrlTrekkoServer(projectUrl).sendCode(SendCodeRequest(email));
  }

  static Future<bool> deleteProfile(String projectUrl, String email) async {
    Isar db = await DatabaseUtils.openProfiles();
    Profile? profile = await db.profiles
        .filter()
        .projectUrlEqualTo(projectUrl)
        .and()
        .emailEqualTo(email)
        .findFirst();
    if (profile == null) {
      return false;
    }

    Isar tripDb = await DatabaseUtils.openTrips(profile.id);
    TrekkoServer server = UrlTrekkoServer.withToken(projectUrl, profile.token);
    return server.deleteAccount().then((value) async {
      return db.writeTxn(() async => db.profiles.delete(profile.id));
    }).then((value) {
      return tripDb.close(deleteFromDisk: true);
    }).then((value) {
      LocationBackgroundTracking.clearCache();
      return value;
    }).then((value) async {
      await db.close();
      return value;
    });
  }

  static Future<bool> isServerValid(String projectUrl) async {
    try {
      String aboutText = await UrlTrekkoServer(projectUrl)
          .getOnboardingText(Endpoint.onboardingTextGoal)
          .then((value) => value.text);
      return aboutText.isNotEmpty;
    } catch (e) {
      return false;
    }
  }
}
