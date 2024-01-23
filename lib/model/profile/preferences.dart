import 'package:app_backend/controller/request/bodies/server_profile.dart';
import 'package:app_backend/model/profile/battery_usage_setting.dart';
import 'package:app_backend/model/profile/question_answer.dart';
import 'package:isar/isar.dart';

part 'preferences.g.dart';

@embedded
class Preferences {

  List<QuestionAnswer> questionAnswers; // TODO: Private
  @enumerated
  BatteryUsageSetting batteryUsageSetting;

  Preferences() : questionAnswers = [], batteryUsageSetting = BatteryUsageSetting.medium;

  Preferences.withData(this.questionAnswers, this.batteryUsageSetting);

  String? getQuestionAnswer(String key) {
    if (this.questionAnswers.any((element) => element.key == key)) {
      return this.questionAnswers.firstWhere((element) => element.key == key).answer;
    }
    return null;
  }

  void setQuestionAnswer(String key, String answer) {
    this.questionAnswers.removeWhere((element) => element.key == key);
    this.questionAnswers.add(QuestionAnswer.withData(key, answer));
  }

  ServerProfile toServerProfile() {
    Map<String, String> data = {};
    this.questionAnswers.forEach((element) {
      data[element.key] = element.answer;
    });
    return ServerProfile(data);
  }
}
