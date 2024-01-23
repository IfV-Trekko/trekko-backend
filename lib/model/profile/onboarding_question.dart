import 'package:app_backend/controller/request/bodies/server_form_entry.dart';
import 'package:app_backend/model/profile/question_answer.dart';
import 'package:app_backend/model/profile/question_type.dart';
import 'package:isar/isar.dart';

part 'onboarding_question.g.dart';

@embedded
class OnboardingQuestion {
  final String key;
  final String title;
  @enumerated
  final QuestionType type;
  final bool? required;
  final String? regex;
  final List<QuestionAnswer>? options;

  OnboardingQuestion()
      : key = "",
        title = '',
        type = QuestionType.text,
        required = false,
        regex = null,
        options = null;

  OnboardingQuestion.withData(this.key, this.title, this.type, this.required,
      this.regex, this.options);

  OnboardingQuestion.fromServer(ServerFormEntry entry)
      :
        this.key = entry.key,
        this.title = entry.title,
        this.type = QuestionType.fromString(entry.type),
        this.required = entry.required,
        this.regex = entry.regex,
        this.options = entry.options?.map((e) =>
            QuestionAnswer.withData(e.key, e.title)).toList();
}
