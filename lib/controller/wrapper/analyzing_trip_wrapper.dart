import 'package:app_backend/controller/utils/position_utils.dart';
import 'package:app_backend/controller/wrapper/leg/analyzing_leg_wrapper.dart';
import 'package:app_backend/controller/wrapper/leg/leg_wrapper.dart';
import 'package:app_backend/controller/wrapper/trip_wrapper.dart';
import 'package:app_backend/model/trip/leg.dart';
import 'package:app_backend/model/trip/trip.dart';
import 'package:fling_units/fling_units.dart';
import 'package:geolocator_platform_interface/src/models/position.dart';

class AnalyzingTripWrapper implements TripWrapper {
  final List<Leg> _legs = List.empty(growable: true);
  LegWrapper _legWrapper = AnalyzingLegWrapper();
  DateTime? newestTimestamp = DateTime.fromMillisecondsSinceEpoch(0);

  @override
  Future<double> calculateEndProbability() {
    return Future.microtask(() async {
      if (_legs.isEmpty || newestTimestamp == null) return 0;
      List<Position> positionsInOrder = _legs
          .expand((element) => element.trackedPoints)
          .map((e) => e.toPosition())
          .toList();
      Duration min = Duration(minutes: 15);
      Duration max = Duration(minutes: 30);
      return PositionUtils.calculateHoldProbability(
          newestTimestamp!, min, max, 200.meters, positionsInOrder);
    });
  }

  @override
  Future<void> add(Position position) async {
    newestTimestamp = position.timestamp;
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
    return Future.microtask(() async {
      return Trip.withData(_legs);
    });
  }
}
