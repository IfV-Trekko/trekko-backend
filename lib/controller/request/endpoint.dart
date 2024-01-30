enum Endpoint {
  signUp("/auth/signup", false),
  signIn("/auth/signin", false),
  forgot_password("auth/forgot-password", false),
  emailConfirm("/account/email/confirmation", false),
  password_reset("/account/password/reset", false),
  onboardingTextAbout("/onboarding/text/about", false),
  onboardingTextGoal("/onboarding/text/goal", false),
  account("/account", true),
  donate("/trips/batch", true),
  trip("/trips/%s", true),
  profile("/profile", true),
  form("/form", true);

  final String path;
  final bool needsAuth;

  const Endpoint(this.path, this.needsAuth);
}
