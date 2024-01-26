import 'package:app_backend/model/profile/onboarding_question.dart';
import 'package:app_backend/model/profile/preferences.dart';
import 'package:app_backend/model/profile/question_answer.dart';
import 'package:app_backend/model/tracking_state.dart';
import 'package:isar/isar.dart';

part 'profile.g.dart';

@collection
class Profile {
  Id id = Isar.autoIncrement;
  final String projectUrl;
  @Index(unique: true, composite: [CompositeIndex("projectUrl")])
  final String email;
  String token;
  DateTime lastLogin;
  @enumerated
  TrackingState trackingState;
  Preferences preferences;

  Profile(this.projectUrl, this.email, this.token, this.lastLogin,
      this.trackingState, this.preferences);
}
