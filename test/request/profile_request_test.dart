import 'package:app_backend/controller/request/bodies/server_profile.dart';
import 'package:app_backend/controller/request/request_exception.dart';
import 'package:app_backend/controller/request/trekko_server.dart';
import 'package:test/test.dart';

import 'request_utils.dart';

void main() {
  late TrekkoServer server;
  setUp(() async {
    server = await RequestUtils.loginOrRegister("realProfileAcc@web.de");
  });

  test("Update wrong preferences", () async {
    try {
      await server.updateProfile(ServerProfile({"MICH_GIBT_ES_NICHT": "huhn"}));
      fail("Expected exception");
    } catch (e) {
      expect(e, isA<RequestException>());
      expect((e as RequestException).code, 400);
    }
  });


  // test("Reading empty profile data", () async {
  //   server.getProfile().onError((error, stackTrace) => expect(error, isA<Exception>())).then((value) {
  //     expect(value, isA<ServerProfile>());
  //     expect(value.name, "");
  //     expect(value.surname, "");
  //     expect(value.email, "");
  //     expect(value.phone, "");
  //     expect(value.address, "");
  //     expect(value.zip, "");
  //     expect(value.city, "");
  //     expect(value.country, "");
  //   });
  // });
}
