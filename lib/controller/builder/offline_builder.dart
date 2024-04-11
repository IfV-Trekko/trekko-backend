import 'package:isar/isar.dart';
import 'package:trekko_backend/controller/builder/trekko_builder.dart';
import 'package:trekko_backend/controller/trekko.dart';
import 'package:trekko_backend/controller/utils/database_utils.dart';
import 'package:trekko_backend/model/profile/preferences.dart';
import 'package:trekko_backend/model/profile/profile.dart';

class OfflineBuilder extends TrekkoBuilder {
  Future<Profile> createProfile() async {
    Isar profileDb = await Databases.profile.getInstance();
    var query = profileDb.profiles
        .filter()
        .emailEqualTo(emailLocal)
        .and()
        .projectUrlEqualTo(projectUrlLocal);

    if (query.isEmptySync()) {
      Profile newProfile =
          Profile(lastLogin: DateTime.now(), preferences: Preferences());
      await profileDb.writeTxn(() async {
        newProfile.id = await profileDb.profiles.put(newProfile);
      });
      return newProfile;
    } else {
      return query.findFirstSync()!;
    }
  }

  @override
  Map<int, Object> getErrorCodes() {
    return {};
  }

  @override
  Future<Trekko> build() async {
    return makeTrekko(await createProfile());
  }
}
