enum Endpoint {
  signUp("/auth/signup", false),
  signIn("/auth/signin", false),
  emailConfirm("/account/email/confirmation", false),
  donate("/trips/batch", true),
  trip("/trips/%s", true),
  profile("/profile", true),
  form("/form", true);

  final String path;
  final bool needsAuth;

  const Endpoint(this.path, this.needsAuth);
}
