import 'package:app_backend/controller/request/endpoint.dart';

enum OnboardingTextType {
  whoText(Endpoint.onboardingTextAbout),
  whatText(Endpoint.onboardingTextGoal);

  final Endpoint endpoint;

  const OnboardingTextType(this.endpoint);
}
