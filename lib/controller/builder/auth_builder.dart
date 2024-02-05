import 'package:app_backend/controller/builder/trekko_builder.dart';

abstract class AuthBuilder extends TrekkoBuilder {

  String? projectUrl;
  String? email;

  AuthBuilder();

  AuthBuilder.withData({this.projectUrl, this.email});

}