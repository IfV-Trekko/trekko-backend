import 'package:isar/isar.dart';

part 'question_answer.g.dart';

@embedded
class QuestionAnswer {
  String key;
  String answer;

  QuestionAnswer()
      : key = "",
        answer = "";

  QuestionAnswer.withData(this.key, this.answer);
}
