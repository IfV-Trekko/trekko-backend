import 'package:app_backend/controller/wrapper/leg/analyzing_leg_wrapper.dart';
import 'package:app_backend/controller/wrapper/leg/leg_wrapper.dart';
import 'package:app_backend/controller/wrapper/trip_wrapper.dart';
import 'package:app_backend/model/trip/donation_state.dart';
import 'package:app_backend/model/trip/leg.dart';
import 'package:app_backend/model/trip/trip.dart';
import 'package:geolocator_platform_interface/src/models/position.dart';

class AnalyzingTripWrapper implements TripWrapper {
  final List<Leg> legs = [];
  LegWrapper legWrapper = AnalyzingLegWrapper();

  @override
  Future<double> calculateEndProbability() {
    return Future.value(0); // TODO: Implement
  }

  @override
  Future<void> add(Position position) async {
    double probability = await legWrapper.calculateEndProbability();
    if (legWrapper.collectedDataPoints() > 0 && probability > 0.9) {
      legs.add(await legWrapper.get());
      legWrapper = AnalyzingLegWrapper();
    } else {
      legWrapper.add(position);
    }
  }

  @override
  int collectedDataPoints() {
    return legs.length;
  }

  @override
  Future<Trip> get() async {
    if (legWrapper.collectedDataPoints() != 0) legs.add(await legWrapper.get());

    Trip trip = Trip(
        donationState: DonationState.undefined,
        startTime: legs[0].trackedPoints[0].timestamp,
        endTime: legs[legs.length - 1]
            .trackedPoints[legs[legs.length - 1].trackedPoints.length - 1]
            .timestamp,
        comment: null,
        purpose: null);

    legs.forEach((element) {
      trip.legs.add(element);
    });
    return Future.value(trip);
  }
}
