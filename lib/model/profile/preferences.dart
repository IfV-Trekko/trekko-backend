import 'package:app_backend/controller/request/bodies/server_profile.dart';
import 'package:app_backend/model/profile/battery_usage_setting.dart';
import 'package:app_backend/model/profile/question_answer.dart';
import 'package:isar/isar.dart';

part 'preferences.g.dart';

@embedded
class Preferences {

  List<QuestionAnswer> onboardingQuestions;
  @enumerated
  BatteryUsageSetting batteryUsageSetting;

  Preferences() : onboardingQuestions = [], batteryUsageSetting = BatteryUsageSetting.medium;

  Preferences.withData(this.onboardingQuestions, this.batteryUsageSetting);

  ServerProfile toServerProfile() {
    Map<String, String> data = {};
    this.onboardingQuestions.forEach((element) {
      data[element.key] = element.answer;
    });
    return ServerProfile(data);
  }
}
