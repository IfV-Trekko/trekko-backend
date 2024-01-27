import 'package:app_backend/controller/builder/build_exception.dart';
import 'package:app_backend/controller/builder/login_builder.dart';
import 'package:app_backend/controller/builder/login_result.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test("Building a Trekko with invalid login data", () async {
    try {
      await LoginBuilder("http://localhost:8080", "notExistingAccount@web.de",
              "1aA!hklj32r4hkjl324ra")
          .build();
      fail("Expected exception");
    } catch (e) {
      expect(e, isA<BuildException>());
      expect((e as BuildException).reason, LoginResult.failedNoSuchUser);
    }
  });

  test("Building a Trekko with invalid server address", () async {
    try {
      await LoginBuilder("http://localhost:8081", "notExistingAccount@web.de",
              "1aA!hklj32r4hkjl324ra")
          .build();
      fail("Expected exception");
    } catch (e) {
      expect(e, isA<BuildException>());
      expect((e as BuildException).reason, LoginResult.failedOther);
    }
  });
}
