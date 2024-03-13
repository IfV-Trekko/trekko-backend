import 'package:app_backend/controller/builder/last_login_builder.dart';
import 'package:app_backend/controller/builder/registration_builder.dart';
import 'package:app_backend/controller/trekko.dart';
import 'package:flutter_test/flutter_test.dart';

import '../trekko_build_utils.dart';

const String email = "lastLoginTest@web.de";
const String password = "1aA!hklj32r4hkjl324r";

void main() {
  setUp(() async {
    // Register new account
    await TrekkoBuildUtils().init();
    Trekko trekko = await RegistrationBuilder.withData(
            projectUrl: TrekkoBuildUtils.getAddress(),
            email: email,
            password: password,
            passwordConfirmation: password,
            code: "12345")
        .build();
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
