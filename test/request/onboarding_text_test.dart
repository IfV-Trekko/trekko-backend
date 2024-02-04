import 'package:app_backend/controller/request/url_trekko_server.dart';
import 'package:app_backend/model/onboarding_text_type.dart';
import 'package:flutter_test/flutter_test.dart';

import 'request_test.dart';

void main() {

  late UrlTrekkoServer server;

  setUpAll(() async {
    server = UrlTrekkoServer(baseUrl);
  });

  test("Check if onboarding text is not empty", () async {
    for (OnboardingTextType type in OnboardingTextType.values) {
      String onboardingText = (await server.getOnboardingText(type.endpoint)).text;
      expect(onboardingText, isNotEmpty);
    }
  });
}