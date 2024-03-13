import 'package:app_backend/controller/request/bodies/server_profile.dart';
import 'package:app_backend/model/profile/battery_usage_setting.dart';
import 'package:app_backend/model/profile/onboarding_question.dart';
import 'package:app_backend/model/profile/question_answer.dart';
import 'package:app_backend/model/profile/question_type.dart';
import 'package:isar/isar.dart';

part 'preferences.g.dart';

@embedded
class Preferences {
  List<QuestionAnswer> questionAnswers; // TODO: Private
  List<OnboardingQuestion> onboardingQuestions;
  @enumerated
  BatteryUsageSetting batteryUsageSetting;

  Preferences()
      : questionAnswers = List.empty(growable: true),
        onboardingQuestions = List.empty(growable: true),
        batteryUsageSetting = BatteryUsageSetting.medium;

  Preferences.withData(
      this.questionAnswers, this.batteryUsageSetting, this.onboardingQuestions);

  dynamic _parseAnswer(String key, dynamic answer) {
    OnboardingQuestion question =
        onboardingQuestions.firstWhere((e) => e.key == key);
    if (question.type == QuestionType.number) {
      return double.parse(answer);
    } else if (question.type == QuestionType.boolean) {
      return answer == "true";
    } else if (question.type == QuestionType.text) {
      return answer.toString();
    } else if (question.type == QuestionType.select) {
      if (!question.options!.any((e) => e.key == answer))
        throw Exception("Invalid answer");
      return answer;
    }
    throw Exception("Unknown question type");
  }

  dynamic getQuestionAnswer(String key) {
    if (this.questionAnswers.any((element) => element.key == key)) {
      return _parseAnswer(
          key,
          this
              .questionAnswers
              .firstWhere((element) => element.key == key)
              .answer);
    }
    return null;
  }

  void setQuestionAnswer(String key, dynamic answer) {
    this.questionAnswers = this.questionAnswers.toList(growable: true);
    if (answer == null) {
      this.questionAnswers.removeWhere((element) => element.key == key);
      return;
    }

    dynamic answerValue = _parseAnswer(key, answer);
    this.questionAnswers.removeWhere((element) => element.key == key);
    this
        .questionAnswers
        .add(QuestionAnswer.withData(key, answerValue.toString()));
  }

  ServerProfile toServerProfile() {
    Map<String, dynamic> data = {};
    this.questionAnswers.forEach((element) {
      data[element.key] = _parseAnswer(element.key, element.answer);
    });
    return ServerProfile(data);
  }
}
