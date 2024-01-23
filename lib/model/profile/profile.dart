import 'package:app_backend/controller/request/bodies/server_profile.dart';
import 'package:app_backend/model/profile/onboarding_question.dart';
import 'package:app_backend/model/profile/preferences.dart';
import 'package:isar/isar.dart';

part 'profile.g.dart';

@collection
class Profile {
  Id id = Isar.autoIncrement;
  @Index(unique: true, replace: true)
  final String projectUrl;
  @Index(unique: true, replace: true)
  final String email;
  final String token;
  final DateTime lastLogin;
  Preferences preferences;

  Profile(this.projectUrl, this.email, this.token, this.lastLogin, this.preferences);

  ServerProfile toServerProfile() {
    Map<String, String> data = {};
    this.preferences.onboardingQuestions.forEach((element) {
      if (element.value != null) data[element.key] = element.value!;
    });
    return ServerProfile(data);
  }
}
