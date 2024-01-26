enum RegistrationResult {
  failedBadCode(1),
  failedWeakPassword(13),
  failedPasswordRepeat(3),
  failedFailedEmail(4),
  failedEmailAlreadyUsed(11),
  failedOther(-1);

  final int _code;

  const RegistrationResult(this._code);

  static Map<int, RegistrationResult> get map => Map.fromIterable(values, key: (e) => e._code, value: (e) => e);
}
