import 'dart:async';
import 'dart:io';

import 'package:trekko_backend/controller/builder/build_exception.dart';
import 'package:trekko_backend/controller/profiled_trekko.dart';
import 'package:trekko_backend/controller/request/request_exception.dart';
import 'package:trekko_backend/controller/trekko.dart';

abstract class TrekkoBuilder {
  FutureOr<T> onError<T>(exception) {
    Map<int, Object> errorCodes = getErrorCodes();
    if (!(exception is RequestException) ||
        exception.reason == null ||
        errorCodes[exception.reason!.reasonCode] == null) {

      if (exception is SocketException) {
        throw BuildException(exception, errorCodes[-2]);
      }

      throw BuildException(exception, getErrorCodes()[-1]);
    }

    throw BuildException(exception, errorCodes[exception.reason!.reasonCode]);
  }

  Future<Trekko> makeTrekko(
      String projectUrl, String email, String token) async {
    Trekko trekko =
        ProfiledTrekko(projectUrl: projectUrl, email: email, token: token);
    await trekko.init();
    return trekko;
  }

  Map<int, Object> getErrorCodes();

  /// Builds the Trekko instance.
  Future<Trekko> build();
}
