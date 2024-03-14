import 'package:app_backend/controller/trekko.dart';
import 'package:app_backend/model/profile/battery_usage_setting.dart';
import 'package:app_backend/model/profile/preferences.dart';
import 'package:app_backend/model/profile/profile.dart';
import 'package:test/test.dart';

import 'trekko_build_utils.dart';

const String password = "1aA!hklj32r4hkjl324r";
const String email = "profile_test113@profile_test.com";

void main() {
  late Trekko trekko;
  setUpAll(() async => trekko = await TrekkoBuildUtils().loginOrRegister(email, password));

  test("Profile data correct", () async {
    Profile profile = await trekko.getProfile().first;
    expect(profile.email, equals(email));
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

    expect(profile.preferences.batteryUsageSetting, equals(BatteryUsageSetting.low));

    await trekko.savePreferences(profile.preferences);
    profile = await trekko.getProfile().first;
    expect(profile.preferences.batteryUsageSetting, equals(BatteryUsageSetting.low));
  });

  tearDownAll(() async => await TrekkoBuildUtils().close(trekko));

  group('Preferences', () {
    late Preferences preferences;

    setUp(() {
      preferences = Preferences();
    });

    test('setQuestionAnswer adds new answer if key does not exist', () {
      preferences.setQuestionAnswer('testKey', 'testAnswer');

      expect(preferences.getQuestionAnswer('testKey'), 'testAnswer');
    });

    test('setQuestionAnswer updates existing answer if key exists', () {
      preferences.setQuestionAnswer('testKey', 'testAnswer');
      preferences.setQuestionAnswer('testKey', 'updatedAnswer');

      expect(preferences.getQuestionAnswer('testKey'), 'updatedAnswer');
    });

    test('getQuestionAnswer returns null if key does not exist', () {
      expect(preferences.getQuestionAnswer('nonExistentKey'), null);
    });

    test('getQuestionAnswer returns correct answer if key exists', () {
      preferences.setQuestionAnswer('testKey', 'testAnswer');

      expect(preferences.getQuestionAnswer('testKey'), 'testAnswer');
    });

    test('toServerProfile returns correct server profile', () {
      preferences.setQuestionAnswer('testKey', 'testAnswer');

      var serverProfile = preferences.toServerProfile();

      expect(serverProfile.data['testKey'], 'testAnswer');
    });
  });
}