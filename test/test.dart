import 'package:app_backend/controller/analysis/calculation_reduction.dart';
import 'package:app_backend/controller/analysis/trip_data.dart';
import 'package:app_backend/controller/builder/build_exception.dart';
import 'package:app_backend/controller/builder/login_builder.dart';
import 'package:app_backend/controller/profiled_trekko.dart';
import 'package:app_backend/model/profile/preferences.dart';
import 'package:app_backend/model/profile/profile.dart';
import 'package:app_backend/model/trip/donation_state.dart';
import 'package:app_backend/model/trip/trip.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:isar/isar.dart';
import 'package:test/test.dart' as test;

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  // runApp(CupertinoApp());

  test.test("Invalid response", () async {
    var builder = LoginBuilder("https://google.de", "test", "test");
    expect(builder.build(), throwsA(predicate((e) => e is BuildException)));
  });

  test.test("Insert trip with legs and tracked points and check if inserted", () async {
    var repo = ProfiledTrekko(Profile("https://google.de", "test", "test", DateTime.now(), Preferences()));
    await repo.init();
    await repo.saveTrip(Trip(
      donationState: DonationState.donated,
      startTime: DateTime.now(),
      endTime: DateTime.now(),
      comment: "test",
      purpose: "test",
      legs: [],
    ));

    test.test("Analyse trip", () async {
      var repo = ProfiledTrekko(Profile("https://google.de", "test", "test", DateTime.now(), Preferences()));

      repo.saveTrip(Trip(
        donationState: DonationState.donated,
        startTime: DateTime.now(),
        endTime: DateTime.now().add(Duration(seconds: 1)),
        comment: "test",
        purpose: "test",
        legs: [],
      ));

      var analysis = await repo.analyze(repo.getTripQuery().build());

      expect((await analysis.first).getData(TripData.duration_in_seconds, CalculationReduction.AVERAGE), 1);
      expect((await analysis.first).getData(TripData.distance_in_meters, CalculationReduction.AVERAGE), 0);
    });

    expect(await repo.getTripQuery().count(), 1);
  });
}
