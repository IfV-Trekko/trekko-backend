enum RegistrationResult {
  failedNoConnection(-2),
  failedBadCode(-4), // Bad request
  failedInvalidCredentials(16),
  failedPasswordRepeat(-3),
  failedFailedEmail(-5), // Request exception
  failedEmailAlreadyUsed(11),
  failedOther(-1);

  final int _code;

  const RegistrationResult(this._code);

  static Map<int, RegistrationResult> get map => Map.fromIterable(values, key: (e) => e._code, value: (e) => e);
}
