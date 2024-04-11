import 'package:trekko_backend/controller/trekko.dart';
import 'package:trekko_backend/model/profile/battery_usage_setting.dart';
import 'package:trekko_backend/model/profile/onboarding_question.dart';
import 'package:trekko_backend/model/profile/preferences.dart';
import 'package:trekko_backend/model/profile/profile.dart';
import 'package:trekko_backend/model/profile/question_type.dart';
import 'package:test/test.dart';

import 'trekko_test_utils.dart';

void main() {
  late Trekko trekko;
  setUpAll(() async => trekko = await TrekkoTestUtils.initTrekko());

  test("Profile data correct", () async {
    Profile profile = await trekko.getProfile().first;
    expect(profile.email, equals(TrekkoTestUtils.email));
  });

  test("Set and get question answer", () async {
    Profile profile = await trekko.getProfile().first;
    profile.preferences.setQuestionAnswer("homeOffice", true);
    profile.preferences.setQuestionAnswer("gender", "female");

    expect(profile.preferences.getQuestionAnswer("homeOffice"), equals(true));
    expect(profile.preferences.getQuestionAnswer("gender"), equals("female"));

    await trekko.savePreferences(profile.preferences);
    profile = await trekko.getProfile().first;
    expect(profile.preferences.getQuestionAnswer("homeOffice"), equals(true));
    expect(profile.preferences.getQuestionAnswer("gender"), equals("female"));
    // expect(profile.preferences.getQuestionAnswer("age"), equals(21));
  });

  test("Set and get battery usage setting", () async {
    Profile profile = await trekko.getProfile().first;
    profile.preferences.batteryUsageSetting = BatteryUsageSetting.low;

    expect(profile.preferences.batteryUsageSetting,
        equals(BatteryUsageSetting.low));

    await trekko.savePreferences(profile.preferences);
    profile = await trekko.getProfile().first;
    expect(profile.preferences.batteryUsageSetting,
        equals(BatteryUsageSetting.low));
  });

  tearDownAll(() async => await TrekkoTestUtils.close(trekko));

  group('preferences test', () {
    late Preferences preferences;

    setUp(() {
      preferences = Preferences.withData(
          questionAnswers: [],
          batteryUsageSetting: BatteryUsageSetting.medium,
          onboardingQuestions: [
            OnboardingQuestion.withData(
                "existingKey", "test", QuestionType.text, false, "*", [])
          ]);
    });

    test('setQuestionAnswer fails if key does not exist', () {
      expect(() => preferences.setQuestionAnswer("nonExistingKey", "test"),
          throwsException);
    });

    test('setQuestionAnswer works if key exists', () {
      preferences.setQuestionAnswer("existingKey", "test");
      expect(preferences.getQuestionAnswer("existingKey"), equals("test"));
    });

    test('override question answer', () {
      preferences.setQuestionAnswer("existingKey", "test");
      preferences.setQuestionAnswer("existingKey", "test2");
      expect(preferences.getQuestionAnswer("existingKey"), equals("test2"));
    });

    test('remove question answer', () {
      preferences.setQuestionAnswer("existingKey", null);
      expect(preferences.getQuestionAnswer("existingKey"), equals(null));
    });
  });
}
