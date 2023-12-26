import 'package:app_backend/controller/trekko.dart';

class TrekkoSignedIn extends Trekko {

  final String token;

  TrekkoSignedIn(this.token);
}