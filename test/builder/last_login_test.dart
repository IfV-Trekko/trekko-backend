import 'package:trekko_backend/controller/builder/build_exception.dart';
import 'package:trekko_backend/controller/builder/last_login_builder.dart';
import 'package:trekko_backend/controller/trekko.dart';
import 'package:trekko_backend/controller/utils/database_utils.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:isar/isar.dart';

import '../trekko_test_utils.dart';

void main() {
  setUp(() async {
    // Register new account
    await TrekkoTestUtils.init();
    Isar db = await Databases.profile.getInstance();
    await db.close(deleteFromDisk: true);
  });

  test("Last login fails if no user has been logged in before", () async {
    LastLoginBuilder lastLoginBuilder = LastLoginBuilder();
    expect(lastLoginBuilder.build(), throwsA(isA<BuildException>()));
  });

  test("Last login works", () async {
    // Last login
    Trekko trekko = await TrekkoTestUtils.initTrekko();
    await trekko.terminate();

    LastLoginBuilder lastLoginBuilder = LastLoginBuilder();
    trekko = await lastLoginBuilder.build();
    expect(trekko, isNotNull);
    await trekko.signOut(delete: true);
  });
}
