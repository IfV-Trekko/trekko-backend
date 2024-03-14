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
    Trekko trekko = await TrekkoBuildUtils().loginOrRegister(email, password);
    await trekko.terminate();
  });

  test("Last login works", () async {
    // Last login
    LastLoginBuilder lastLoginBuilder = LastLoginBuilder();
    Trekko? trekko = await lastLoginBuilder.build();
    expect(trekko, isNotNull);
    await trekko.signOut(delete: true);
  });
}
