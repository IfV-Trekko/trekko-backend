DateTime dateTimeFromJson(int value) {
  return DateTime.fromMillisecondsSinceEpoch(value);
}

int dateTimeToJson(DateTime value) {
  return value.millisecondsSinceEpoch.toInt();
}
