enum RegistrationResult {
  success(0),
  failedBadCode(1),
  failedWeakPassword(2),
  failedPasswordRepeat(3),
  failedFailedEmail(4),
  failedEmailAlreadyUsed(5),
  failedOther(-1);

  final int code;

  const RegistrationResult(this.code);

  static Map<int, RegistrationResult> get map => Map.fromIterable(values, key: (e) => e._code, value: (e) => e);
}
