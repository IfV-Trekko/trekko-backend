import 'package:app_backend/model/account/preferences.dart';
import 'package:isar/isar.dart';

@collection
class Profile {

  final Id id = Isar.autoIncrement;
  final String projectUrl;
  final String email;
  final String token;
  final Preferences preferences;

  Profile(this.projectUrl, this.email, this.token, this.preferences);
}