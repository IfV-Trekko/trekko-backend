import 'dart:async';
import 'dart:io';

import 'package:trekko_backend/controller/builder/build_exception.dart';
import 'package:trekko_backend/controller/offline_trekko.dart';
import 'package:trekko_backend/controller/online_trekko.dart';
import 'package:trekko_backend/controller/request/request_exception.dart';
import 'package:trekko_backend/controller/trekko.dart';
import 'package:trekko_backend/model/profile/profile.dart';

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

  Future<Trekko> makeTrekko(Profile profile) async {
    Trekko trekko = profile.isOnline() ? OnlineTrekko() : OfflineTrekko();
    await trekko.init(profile.id);
    return trekko;
  }

  Map<int, Object> getErrorCodes();

  /// Builds the Trekko instance.
  Future<Trekko> build();
}
