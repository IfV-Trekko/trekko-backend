import 'package:app_backend/controller/utils/position_utils.dart';
import 'package:app_backend/controller/wrapper/leg/analyzing_leg_wrapper.dart';
import 'package:app_backend/controller/wrapper/leg/leg_wrapper.dart';
import 'package:app_backend/controller/wrapper/trip_wrapper.dart';
import 'package:app_backend/model/position.dart';
import 'package:app_backend/model/trip/leg.dart';
import 'package:app_backend/model/trip/trip.dart';
import 'package:fling_units/fling_units.dart';

class AnalyzingTripWrapper implements TripWrapper {
  final List<Leg> _legs = List.empty(growable: true);
  LegWrapper _legWrapper = AnalyzingLegWrapper();
  DateTime? newestTimestamp = DateTime.fromMillisecondsSinceEpoch(0);
  Duration _minDuration = Duration(minutes: 25);
  DateTime? oldestTimestamp;

  @override
  Future<double> calculateEndProbability() {
    return Future.microtask(() async {
      if (_legs.isEmpty || newestTimestamp == null || oldestTimestamp == null)
        return 0;
      if (newestTimestamp!.difference(oldestTimestamp!) < _minDuration ||
          await _legWrapper.hasStartedMoving()) return 0;
      List<Position> positionsInOrder = _legs
          .expand((element) => element.trackedPoints)
          .map((e) => e.toPosition())
          .toList();
      return PositionUtils.calculateSingleHoldProbability(
          newestTimestamp!.subtract(_minDuration),
          _minDuration,
          meters(200),
          positionsInOrder);
    });
  }

  @override
  Future<void> add(Position position) async {
    if (oldestTimestamp == null) {
      oldestTimestamp = position.timestamp;
    }

    if (newestTimestamp != null && position.timestamp.isBefore(newestTimestamp!))
      throw Exception(
          "Positions must be added in chronological order. Newest timestamp: $newestTimestamp, new timestamp: ${position.timestamp}");

    newestTimestamp = position.timestamp;
    double probability = await _legWrapper.calculateEndProbability();
    if (probability > 0.95) {
      _legs.add(await _legWrapper.get());
      _legWrapper = AnalyzingLegWrapper();
    } else {
      _legWrapper.add(position);
    }
  }

  @override
  Future<Trip> get() async {
    return Future.microtask(() async {
      return Trip.withData(_legs);
    });
  }
}
