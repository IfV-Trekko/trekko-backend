import 'dart:async';

import 'package:app_backend/controller/builder/build_exception.dart';
import 'package:app_backend/controller/request/request_exception.dart';
import 'package:app_backend/controller/trekko.dart';

abstract class TrekkoBuilder {

  FutureOr<T> onError<T>(exception) {
    if (!(exception is RequestException)) {
      throw exception;
    }

    if (exception.reason == null) {
      throw BuildException(getErrorCodes()[-1]);
    }

    throw BuildException(getErrorCodes()[exception.reason!.reasonCode]);
  }

  Map<int, Object> getErrorCodes();

  Future<Trekko> build();

}