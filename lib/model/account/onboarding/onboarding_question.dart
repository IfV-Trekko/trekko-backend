import 'package:isar/isar.dart';

@embedded
class OnboardingQuestion {
  final int id;
  final String name;
  final bool required;
  final String? regex;
  final List<String>? options;
  String? value;

  OnboardingQuestion() : id = -1, name = '', required = false, regex = null, options = null;

  OnboardingQuestion.withData(this.id, this.name, this.required, this.regex, this.options);
}