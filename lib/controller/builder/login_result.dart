enum LoginResult {
  failedWrongPassword(1),
  failedNoSuchEmail(2),
  failedSessionExpired(3),
  failedOther(-1);

  final int code;

  const LoginResult(this.code);

  static Map<int, LoginResult> get map => Map.fromIterable(values, key: (e) => e._code, value: (e) => e);
}
