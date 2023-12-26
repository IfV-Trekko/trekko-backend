
enum Endpoint {
  signUp(
    "/auth/signup",
    false
  ),
  signIn(
    "/auth/signin",
    false
  ),
  donate(
    "/trips/batch",
    true
  ),
  trip(
    "/trips/%s",
    true
  );

  final String path;
  final bool needsAuth;

  const Endpoint(this.path, this.needsAuth);

}
