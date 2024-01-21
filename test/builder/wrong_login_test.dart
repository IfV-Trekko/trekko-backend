import 'package:app_backend/controller/builder/build_exception.dart';
import 'package:app_backend/controller/builder/login_builder.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test("Building a Trekko with invalid login data", () {
    LoginBuilder("http://localhost:8080", "notExisting@test.de", "test").build().then((value) {
      fail("Expected exception");
    }).catchError((e) {
      expect(e, isA<BuildException>());
    });
  });
}