import 'package:app_backend/controller/builder/build_exception.dart';
import 'package:app_backend/controller/builder/login_builder.dart';
import 'package:test/test.dart';

void main() {
  test("Invalid response", () async {
    var builder = LoginBuilder("https://google.de", "test", "test");
    expect(builder.build(), throwsA(predicate((e) => e is BuildException)));
  });
}
