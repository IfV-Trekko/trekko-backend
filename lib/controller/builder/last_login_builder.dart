import 'dart:async';

import 'package:app_backend/controller/builder/login_result.dart';
import 'package:app_backend/controller/builder/trekko_builder.dart';
import 'package:app_backend/controller/profiled_trekko.dart';
import 'package:app_backend/controller/trekko.dart';
import 'package:app_backend/controller/utils/database_utils.dart';
import 'package:app_backend/model/profile/profile.dart';
import 'package:isar/isar.dart';

class LastLoginBuilder extends TrekkoBuilder {
  Isar? _database;

  Future<Isar> _getDatabase() async {
    return _database ?? (_database = await DatabaseUtils.establishConnection());
  }

  Future<bool> hasData() async {
    return await (await _getDatabase()).profiles.count() > 0;
  }

  @override
  Map<int, Object> getErrorCodes() {
    return LoginResult.map;
  }

  @override
  Future<Trekko> build() {
    return _getDatabase().then((value) async {
      if (await hasData() == false) {
        throw Exception("No last profile found.");
      }

      Profile? latestProfile =
          await value.profiles.where().sortByLastLoginDesc().findFirst();
      return ProfiledTrekko(
          projectUrl: latestProfile!.projectUrl,
          email: latestProfile.email,
          token: latestProfile.token);
    });
  }
}
