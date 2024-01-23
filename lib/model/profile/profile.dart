import 'package:app_backend/model/profile/onboarding_question.dart';
import 'package:app_backend/model/profile/preferences.dart';
import 'package:app_backend/model/profile/question_answer.dart';
import 'package:app_backend/model/tracking_state.dart';
import 'package:isar/isar.dart';

part 'profile.g.dart';

@collection
class Profile {
  Id id = Isar.autoIncrement;
  @Index(unique: true)
  final String projectUrl;
  @Index(unique: true)
  final String email;
  String token;
  DateTime lastLogin;
  @enumerated
  TrackingState trackingState = TrackingState.paused;
  List<OnboardingQuestion> onboardingQuestions;
  Preferences preferences;

  Profile(this.projectUrl, this.email, this.token, this.lastLogin,
      this.trackingState, this.onboardingQuestions, this.preferences);
}
