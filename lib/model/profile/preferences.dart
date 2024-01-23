import 'package:app_backend/controller/request/bodies/server_profile.dart';
import 'package:app_backend/model/profile/battery_usage_setting.dart';
import 'package:app_backend/model/profile/question_answer.dart';
import 'package:isar/isar.dart';

part 'preferences.g.dart';

@embedded
class Preferences {

  List<QuestionAnswer> _questionAnswers;
  @enumerated
  BatteryUsageSetting batteryUsageSetting;

  Preferences() : _questionAnswers = [], batteryUsageSetting = BatteryUsageSetting.medium;

  Preferences.withData(this._questionAnswers, this.batteryUsageSetting);

  QuestionAnswer getQuestionAnswer(String key) {
    return this._questionAnswers.firstWhere((element) => element.key == key);
  }

  void setQuestionAnswer(String key, String answer) {
    this._questionAnswers.removeWhere((element) => element.key == key);
    this._questionAnswers.add(QuestionAnswer.withData(key, answer));
  }

  ServerProfile toServerProfile() {
    Map<String, String> data = {};
    this._questionAnswers.forEach((element) {
      data[element.key] = element.answer;
    });
    return ServerProfile(data);
  }
}
