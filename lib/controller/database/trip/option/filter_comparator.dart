enum FilterComparator {
  equal("="),
  notEqual("!="),
  greaterThan(">"),
  greaterThanOrEqual(">="),
  lessThan("<"),
  lessThanOrEqual("<=");

  final String value;

  const FilterComparator(this.value);
}