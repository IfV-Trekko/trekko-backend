import 'dart:async';

import 'package:app_backend/controller/builder/build_exception.dart';
import 'package:app_backend/controller/builder/login_result.dart';
import 'package:app_backend/controller/builder/trekko_builder.dart';
import 'package:app_backend/controller/request/request_exception.dart';
import 'package:app_backend/controller/request/url_trekko_server.dart';
import 'package:app_backend/controller/trekko.dart';
import 'package:app_backend/controller/utils/database_utils.dart';
import 'package:app_backend/model/profile/profile.dart';
import 'package:isar/isar.dart';

class LastLoginBuilder extends TrekkoBuilder {
  @override
  Map<int, Object> getErrorCodes() {
    return LoginResult.map;
  }

  @override
  Future<Trekko> build() {
    return DatabaseUtils.openProfiles().then((value) async {
      Profile? latestProfile =
          await value.profiles.where().sortByLastLoginDesc().findFirst();
      if (latestProfile == null) {
        await value.close();
        throw new BuildException(null, LoginResult.failedNoSuchUser);
      }

      try {
        await UrlTrekkoServer.withToken(
                latestProfile.projectUrl, latestProfile.token)
            .getUser();
      } on RequestException catch (e) {
        if ((e.code == 404 || e.code == 403)) {
          // Delete the profile from the database
          await value.profiles.filter().idEqualTo(latestProfile.id).deleteAll();
          value.close();
          throw BuildException(e, LoginResult.failedSessionExpired);
        }
      } finally {
        await value.close();
      }

      await value.close();
      return makeTrekko(
          latestProfile.projectUrl, latestProfile.email, latestProfile.token);
    });
  }
}
