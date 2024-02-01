import 'package:app_backend/controller/builder/authentification_utils.dart';
import 'package:app_backend/controller/builder/build_exception.dart';
import 'package:app_backend/controller/builder/last_login_builder.dart';
import 'package:app_backend/controller/builder/registration_builder.dart';
import 'package:app_backend/controller/builder/registration_result.dart';
import 'package:app_backend/controller/trekko.dart';
import 'package:flutter_test/flutter_test.dart';

import '../trekko_build_utils.dart';

const String ip = "http://localhost:8080";
const String email = "lastLoginTest@web.de";
const String password = "1aA!hklj32r4hkjl324r";

void main() {
  setUp(() async {
    // Register new account
    await TrekkoBuildUtils().init();
    try {
      Trekko trekko =
          await RegistrationBuilder("http://localhost:8080", email, password, password, "12345").build();
      await trekko.terminate();
    } catch (e) {
      if (e is BuildException) {
        expect((e).reason, RegistrationResult.failedEmailAlreadyUsed);
      } else {
        throw e;
      }
    }
  });

  test("Last login works", () async {
    // Last login
    LastLoginBuilder lastLoginBuilder = LastLoginBuilder();
    expect(await lastLoginBuilder.hasData(), true);
    Trekko? trekko = await lastLoginBuilder.build();
    expect(trekko, isNotNull);
    await trekko.terminate();
  });

  tearDown(() async {
    await AuthentificationUtils.deleteProfile(ip, email);
  });
}
