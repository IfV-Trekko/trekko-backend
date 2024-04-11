import 'dart:async';

import 'package:trekko_backend/controller/builder/build_exception.dart';
import 'package:trekko_backend/controller/builder/login_result.dart';
import 'package:trekko_backend/controller/builder/trekko_builder.dart';
import 'package:trekko_backend/controller/request/request_exception.dart';
import 'package:trekko_backend/controller/request/url_trekko_server.dart';
import 'package:trekko_backend/controller/trekko.dart';
import 'package:trekko_backend/controller/utils/database_utils.dart';
import 'package:trekko_backend/model/profile/profile.dart';
import 'package:isar/isar.dart';

class LastLoginBuilder extends TrekkoBuilder {
  @override
  Map<int, Object> getErrorCodes() {
    return LoginResult.map;
  }

  @override
  Future<Trekko> build() async {
    Isar profileDb = await Databases.profile.getInstance();
    Profile? latestProfile =
        await profileDb.profiles.where().sortByLastLoginDesc().findFirst();
    if (latestProfile == null) {
      throw new BuildException(null, LoginResult.failedNoSuchUser);
    }

    if (latestProfile.isOnline()) {
      try {
        await UrlTrekkoServer.withToken(
                latestProfile.projectUrl, latestProfile.token)
            .getUser();
      } on RequestException catch (e) {
        if ((e.code == 404 || e.code == 403)) {
          throw BuildException(e, LoginResult.failedSessionExpired);
        }
        rethrow;
      }
    }

    return makeTrekko(latestProfile);
  }
}
