import 'dart:async';

import 'package:app_backend/controller/builder/build_exception.dart';
import 'package:app_backend/controller/profiled_trekko.dart';
import 'package:app_backend/controller/request/request_exception.dart';
import 'package:app_backend/controller/trekko.dart';
import 'package:app_backend/model/profile/preferences.dart';
import 'package:app_backend/model/profile/profile.dart';

abstract class TrekkoBuilder {
  FutureOr<T> onError<T>(exception) {
    Map<int, Object> errorCodes = getErrorCodes();
    if (!(exception is RequestException) || exception.reason == null ||
        errorCodes[exception.reason!.reasonCode] == null) {
      throw BuildException(exception, getErrorCodes()[-1]);
    }

    throw BuildException(exception, errorCodes[exception.reason!.reasonCode]);
  }

  Future<Trekko> makeTrekko(String projectUrl, String email, String token) async {
    Trekko trekko = ProfiledTrekko(Profile(projectUrl, email, token, DateTime.now(), Preferences()));
    await trekko.init();
    return trekko;
  }

  Map<int, Object> getErrorCodes();

  Future<Trekko> build();
}
