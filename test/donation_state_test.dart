import 'package:app_backend/controller/trekko.dart';
import 'package:app_backend/model/tracking_state.dart';
import 'package:test/test.dart';

import 'trekko_build_utils.dart';

const String password = "1aA!hklj32r4hkjl324r";
const String email = "tracking_test@profile_test.com";

void main() {
  late Trekko trekko;
  setUpAll(() async => trekko = await TrekkoBuildUtils().loginOrRegister(email, password));

  test("Setting unchanged tracking state", () async {
    // Paused by default
    bool changed = await trekko.setTrackingState(TrackingState.paused);
    expect(changed, equals(false));
  });

  // test("Setting changed tracking state", () async {
  //   bool changed = await trekko.setTrackingState(TrackingState.running);
  //   expect(changed, equals(true));
  // });

  tearDownAll(() async => await TrekkoBuildUtils().close(trekko));
}