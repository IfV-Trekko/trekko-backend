import 'package:app_backend/controller/request/bodies/server_profile.dart';
import 'package:app_backend/model/account/onboarding/onboarding_question.dart';
import 'package:app_backend/model/account/preferences.dart';
import 'package:isar/isar.dart';

part 'profile.g.dart';

@collection
class Profile {

  final Id id = Isar.autoIncrement;
  final String projectUrl;
  final String email;
  final String token;
  final Preferences preferences;

  Profile(this.projectUrl, this.email, this.token, this.preferences);

  ServerProfile toServerProfile() {
    Map<String, String> data = {};
    this.preferences.onboardingQuestions.forEach((element) {
      if (element.value != null) data[element.key] = element.value!;
    });
    return ServerProfile(data);
  }
}