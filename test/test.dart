import 'package:app_backend/controller/builder/build_exception.dart';
import 'package:app_backend/controller/builder/login_builder.dart';
import 'package:app_backend/controller/database/trip/trip_repository.dart';
import 'package:app_backend/model/trip/donation_state.dart';
import 'package:app_backend/model/trip/trip.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:test/test.dart' as test;

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  // runApp(CupertinoApp());

  test.test("Invalid response", () async {
    var builder = LoginBuilder("https://google.de", "test", "test");
    expect(builder.build(), throwsA(predicate((e) => e is BuildException)));
  });

  test.test("Insert trip with legs and tracked points and check if inserted", () async {
    var repo = TripRepository();
    await repo.addTrip(Trip(
      uid: "test",
      donationState: DonationState.donated,
      startTime: DateTime.now(),
      endTime: DateTime.now(),
      comment: "test",
      purpose: "test",
    ));

    await repo.watchTrips().listen((event) {
      print(event);
    });
  });
}
