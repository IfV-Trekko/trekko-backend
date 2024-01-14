import 'package:app_backend/controller/utils/position_utils.dart';
import 'package:app_backend/controller/wrapper/leg/analyzing_leg_wrapper.dart';
import 'package:app_backend/controller/wrapper/leg/leg_wrapper.dart';
import 'package:app_backend/controller/wrapper/trip_wrapper.dart';
import 'package:app_backend/model/trip/donation_state.dart';
import 'package:app_backend/model/trip/leg.dart';
import 'package:app_backend/model/trip/trip.dart';
import 'package:geolocator_platform_interface/src/models/position.dart';

class AnalyzingTripWrapper implements TripWrapper {
  final List<Leg> _legs = [];
  LegWrapper _legWrapper = AnalyzingLegWrapper();

  @override
  Future<double> calculateEndProbability() {
    return PositionUtils.calculateEndProbability(
        Duration(minutes: 15),
        9,
        _legs
            .expand(
                (element) => element.trackedPoints.map((t) => t.toPosition()))
            .toList());
  }

  @override
  Future<void> add(Position position) async {
    double probability = await _legWrapper.calculateEndProbability();
    if (_legWrapper.collectedDataPoints() > 0 && probability > 0.9) {
      _legs.add(await _legWrapper.get());
      _legWrapper = AnalyzingLegWrapper();
    } else {
      _legWrapper.add(position);
    }
  }

  @override
  int collectedDataPoints() {
    return _legs.length;
  }

  @override
  Future<Trip> get() async {
    if (_legWrapper.collectedDataPoints() != 0)
      _legs.add(await _legWrapper.get());

    Trip trip = Trip(
        donationState: DonationState.undefined,
        startTime: _legs[0].trackedPoints[0].timestamp,
        endTime: _legs[_legs.length - 1]
            .trackedPoints[_legs[_legs.length - 1].trackedPoints.length - 1]
            .timestamp,
        comment: null,
        purpose: null,
        legs: []);

    _legs.forEach((element) {
      trip.legs.add(element);
    });
    return Future.value(trip);
  }
}
