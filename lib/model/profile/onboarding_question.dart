import 'package:isar/isar.dart';

part 'onboarding_question.g.dart';

@embedded
class OnboardingQuestion {
  final String key;
  final String title;
  final bool required;
  final String? regex;
  final List<String>? options;
  String? value;

  OnboardingQuestion()
      : key = "",
        title = '',
        required = false,
        regex = null,
        options = null;

  OnboardingQuestion.withData(
      this.key, this.title, this.required, this.regex, this.options, this.value);
}
