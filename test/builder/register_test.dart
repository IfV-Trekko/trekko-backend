import 'package:trekko_backend/controller/builder/build_exception.dart';
import 'package:trekko_backend/controller/builder/registration_builder.dart';
import 'package:trekko_backend/controller/builder/registration_result.dart';
import 'package:test/test.dart';

void main() {
  test("Building a Trekko with invalid login data", () async {
    try {
      await RegistrationBuilder.withData(
              projectUrl: "http://localhost:8080",
              email: "notExistingAccount@web.de",
              password: "abc",
              passwordConfirmation: "notAbc",
              code: "12345")
          .build();
      fail("Expected exception");
    } catch (e) {
      expect(e, isA<BuildException>());
      expect((e as BuildException).reason,
          RegistrationResult.failedPasswordRepeat);
    }
  });

  test("Building a Trekko with invalid code", () async {
    try {
      await RegistrationBuilder.withData(
              projectUrl: "http://localhost:8080",
              email: "notExistingAccount@web.de",
              password: "abc",
              passwordConfirmation: "abc",
              code: "")
          .build();
    } catch (e) {
      expect(e, isA<BuildException>());
      expect((e as BuildException).reason, RegistrationResult.failedBadCode);
    }
  });

  test("Building a Trekko with invalid server address", () async {
    try {
      await RegistrationBuilder.withData(
              projectUrl: "http://localhost:8081",
              email: "notExistingAccount@web.de",
              password: "abc",
              passwordConfirmation: "abc",
              code: "12345")
          .build();
    } catch (e) {
      expect(e, isA<BuildException>());
      expect(
          (e as BuildException).reason, RegistrationResult.failedNoConnection);
    }
  });
}
