import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:trekko_backend/controller/trekko.dart';
import 'package:trekko_backend/model/tracking/cache/raw_phone_data_type.dart';
import 'package:trekko_backend/model/tracking/raw_phone_data.dart';
import 'package:trekko_backend/model/tracking_state.dart';
import 'package:trekko_backend/model/trip/trip.dart';

import '../utils/trekko_test_utils.dart';
import '../utils/tracking_test_util.dart';

void main() {
  Trekko? trekko;

  setUp(() async {
    await TrekkoTestUtils.init();
    await TrekkoTestUtils.clear();
  });

  test("Send big data dump to cache", () async {
    File file = File(
        "test_resources/position_data.json"); // This file is not included in the repository, you may provide your own position data extracted from a phone
    if (!await file.exists()) {
      print("File does not exist");
      return;
    }

    String data = await file.readAsString();
    List<dynamic> positions = jsonDecode(data);
    List<RawPhoneData> parsed =
        positions.map((e) => RawPhoneDataType.parseData(e)).toList();

    await TrackingTestUtil.sendToCache(parsed);
    trekko = await TrekkoTestUtils.initTrekko(signOut: false);
    trekko!.setTrackingState(TrackingState.running);
    await TrackingTestUtil.waitForFinishProcessing(trekko!);

    List<Trip> trips = trekko!.getTripQuery().build().findAllSync();
    print(trips.length);
    for (Trip trip in trips) {
      print(trip.calculateStartTime().toIso8601String());
      print(trip.calculateEndTime().toIso8601String());
    }
  }, timeout: Timeout(Duration(minutes: 5)));

  tearDown(() async {
    if (trekko == null) return;
    await TrekkoTestUtils.close(trekko!);
  });
}
