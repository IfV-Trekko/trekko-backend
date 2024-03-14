import 'package:app_backend/controller/request/bodies/response/form_response.dart';
import 'package:app_backend/controller/request/trekko_server.dart';
import 'package:test/test.dart';

import 'request_utils.dart';

void main() {
  late TrekkoServer server;
  setUp(() async {
    server = await RequestUtils.loginOrRegister("realFormAcc@web.de");
  });

  test('Get form from server and check not empty', () async {
    FormResponse response = await server.getForm();
    expect(response.fields, isNotEmpty);
  });


}