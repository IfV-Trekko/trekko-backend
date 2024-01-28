enum LoginResult {
  failedNoConnection(-2),
  failedWrongPassword(12),
  failedNoSuchUser(14),
  failedSessionExpired(20),
  failedOther(-1);

  final int _code;

  const LoginResult(this._code);

  static Map<int, LoginResult> get map => Map.fromIterable(values, key: (e) => e._code, value: (e) => e);
}
