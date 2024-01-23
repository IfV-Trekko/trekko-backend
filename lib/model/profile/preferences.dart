import 'package:app_backend/model/profile/battery_usage_setting.dart';
import 'package:app_backend/model/profile/onboarding_question.dart';
import 'package:isar/isar.dart';

part 'preferences.g.dart';

@embedded
class Preferences {
  final List<OnboardingQuestion> onboardingQuestions;
  final BatteryUsageSetting batteryUsageSetting;

  Preferences() : onboardingQuestions = [], batteryUsageSetting = BatteryUsageSetting.medium;

  Preferences.withData(this.onboardingQuestions, this.batteryUsageSetting);
}
