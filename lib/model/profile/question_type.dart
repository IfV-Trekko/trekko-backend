enum QuestionType {
  boolean("boolean"),
  select("select"),
  number("number"),
  text("text");

  final String name;

  const QuestionType(this.name);

  static QuestionType fromString(String name) {
    return QuestionType.values.firstWhere((e) => e.name == name);
  }
}
