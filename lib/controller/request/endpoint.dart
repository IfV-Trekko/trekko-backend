enum Endpoint<S, R> {
  signUp<AuthRequest, AuthResponse>(
    "/auth/signup",
    false,
    (String body) => AuthResponse.fromJson(body),
    (AuthBody body) => body.toJson(),
  ),
  signIn(
    "/auth/signin",
    false,
    (String body) => AuthResponse.fromJson(body),
    (AuthBody body) => body.toJson(),
  ),
  donate(
    "/trips/donate",
    true,
  ),
  trip(
    "/trips/%s",
    true,
  );

  final String path;
  final bool needsAuth;
  final R Function(String) responseParser;
  final String Function(S) requestParser;

  const Endpoint(
      this.path, this.needsAuth, this.responseParser, this.requestParser);
}
