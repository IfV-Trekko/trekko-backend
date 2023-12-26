import 'package:app_backend/controller/builder/trekko_builder.dart';
import 'package:app_backend/controller/trekko.dart';

class LoginBuilder implements TrekkoBuilder {

  final String projectUrl;
  final String email;
  final String password;

  LoginBuilder(this.projectUrl, this.email, this.password);

  @override
  Future<Trekko> build() {
    return Future.value(null);
  }
}