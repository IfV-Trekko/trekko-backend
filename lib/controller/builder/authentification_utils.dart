import 'package:trekko_backend/controller/request/bodies/request/send_code_request.dart';
import 'package:trekko_backend/controller/request/endpoint.dart';
import 'package:trekko_backend/controller/request/url_trekko_server.dart';

class AuthentificationUtils {
  static Future<void> sendCode(String projectUrl, String email) {
    return UrlTrekkoServer(projectUrl).sendCode(SendCodeRequest(email));
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
