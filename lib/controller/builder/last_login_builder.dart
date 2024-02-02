import 'dart:async';

import 'package:app_backend/controller/builder/build_exception.dart';
import 'package:app_backend/controller/builder/login_result.dart';
import 'package:app_backend/controller/builder/trekko_builder.dart';
import 'package:app_backend/controller/trekko.dart';
import 'package:app_backend/controller/utils/database_utils.dart';
import 'package:app_backend/model/profile/profile.dart';
import 'package:isar/isar.dart';

class LastLoginBuilder extends TrekkoBuilder {
  Isar? _database;

  Future<Isar> _getDatabase() async {
    return _database ??
        (_database = await DatabaseUtils.establishConnection(
            [ProfileSchema], "lastLogin"));
  }

  @override
  Map<int, Object> getErrorCodes() {
    return LoginResult.map;
  }

  @override
  Future<Trekko> build() {
    return _getDatabase().then((value) async {
      Profile? latestProfile =
          await value.profiles.where().sortByLastLoginDesc().findFirst();
      await _database!.close();
      if (latestProfile == null)
        throw new BuildException(null, LoginResult.failedNoSuchUser);
      // TODO: Check if token is still valid
      return makeTrekko(
          latestProfile.projectUrl, latestProfile.email, latestProfile.token);
    });
  }
}
