class OnboardingQuestion {
  final int id;
  final String name;
  final bool required;
  final String? regex;
  final List<String>? options;

  OnboardingQuestion(this.id, this.name, this.required, this.regex, this.options);
}