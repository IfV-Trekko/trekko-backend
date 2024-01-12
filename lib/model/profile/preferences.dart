import 'package:app_backend/model/profile/onboarding_question.dart';
import 'package:isar/isar.dart';

part 'preferences.g.dart';

@embedded
class Preferences {

  final List<OnboardingQuestion> onboardingQuestions = [];

}