import 'package:app_backend/controller/builder/build_exception.dart';
import 'package:app_backend/controller/builder/last_login_builder.dart';
import 'package:app_backend/controller/trekko.dart';
import 'package:flutter_test/flutter_test.dart';

import '../trekko_build_utils.dart';

const String email = "lastLoginTest2@web.de";
const String password = "1aA!hklj32r4hkjl324r";

void main() {
  setUp(() async {
    // Register new account
    await TrekkoBuildUtils().init();
  });

  test("Last login fails if no user has been logged in before", () async {
    LastLoginBuilder lastLoginBuilder = LastLoginBuilder();
    expect(lastLoginBuilder.build(), throwsA(isA<BuildException>()));
  });

  test("Last login works", () async {
    // Last login
    Trekko trekko = await TrekkoBuildUtils().loginOrRegister(email, password);
    await trekko.terminate();

    LastLoginBuilder lastLoginBuilder = LastLoginBuilder();
    trekko = await lastLoginBuilder.build();
    expect(trekko, isNotNull);
    await trekko.signOut(delete: true);
  });
}
