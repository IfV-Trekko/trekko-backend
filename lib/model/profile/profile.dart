import 'package:trekko_backend/model/profile/onboarding_question.dart';
import 'package:trekko_backend/model/profile/preferences.dart';
import 'package:trekko_backend/model/profile/question_answer.dart';
import 'package:trekko_backend/model/tracking_state.dart';
import 'package:isar/isar.dart';

part 'profile.g.dart';

const String projectUrlLocal = "local";
const String emailLocal = "anonymous";

@collection
class Profile {

  Id id = Isar.autoIncrement;
  String projectUrl;
  @Index(unique: true, composite: [CompositeIndex("projectUrl")], replace: true)
  String email;
  String? token;
  DateTime lastLogin;
  DateTime? lastTimeTracked;
  @enumerated
  TrackingState trackingState;
  Preferences preferences;

  Profile({
    this.projectUrl = projectUrlLocal,
    this.email = emailLocal,
    this.token,
    this.lastTimeTracked,
    this.trackingState = TrackingState.paused,
    required this.lastLogin,
    required this.preferences,
  });

  bool isOnline() {
    return projectUrl != projectUrlLocal && email != emailLocal;
  }
}
