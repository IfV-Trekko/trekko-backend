import 'package:trekko_backend/controller/trekko.dart';
import 'package:trekko_backend/model/tracking_state.dart';
import 'package:test/test.dart';

import 'utils/trekko_test_utils.dart';

void main() {
  late Trekko trekko;
  setUpAll(() async => trekko = await TrekkoTestUtils.initTrekko(online: true));

  test("Setting unchanged tracking state", () async {
    // Paused by default
    bool changed = await trekko.setTrackingState(TrackingState.paused);
    expect(changed, equals(false));
  });

  test("Setting changed tracking state", () async {
    bool changed = await trekko.setTrackingState(TrackingState.running);
    expect(changed, equals(true));
  });

  tearDownAll(() async => await TrekkoTestUtils.close(trekko));
}