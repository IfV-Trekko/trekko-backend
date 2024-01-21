enum LoginResult {
  failedWrongPassword(1),
  failedNoSuchUser(14),
  failedSessionExpired(3),
  failedOther(-1);

  final int _code;

  const LoginResult(this._code);

  static Map<int, LoginResult> get map => Map.fromIterable(values, key: (e) => e._code, value: (e) => e);
}
