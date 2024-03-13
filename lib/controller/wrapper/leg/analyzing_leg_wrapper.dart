import 'package:app_backend/controller/utils/position_utils.dart';
import 'package:app_backend/controller/wrapper/leg/leg_wrapper.dart';
import 'package:app_backend/controller/wrapper/leg/position/transport_type_data.dart';
import 'package:app_backend/controller/wrapper/leg/position/weighted_transport_type_evaluator.dart';
import 'package:app_backend/model/position.dart';
import 'package:app_backend/model/trip/leg.dart';
import 'package:app_backend/model/trip/tracked_point.dart';
import 'package:fling_units/fling_units.dart';

class AnalyzingLegWrapper implements LegWrapper {
  static const Duration _stayDuration = Duration(minutes: 2);
  static Distance _stayDistance = meters(50);

  List<Position> _positions = List.empty(growable: true);
  Position? _startedMoving;

  Future<double> calculateProbability(TransportTypeData data) {
    WeightedTransportTypeEvaluator evaluator =
        WeightedTransportTypeEvaluator(data);
    Leg leg = Leg();
    leg.trackedPoints = _positions.map(TrackedPoint.fromPosition).toList();
    return evaluator.evaluate(leg);
  }

  Position? cluster(List<Position> positions) {
    List<Position> firstIn =
        PositionUtils.getFirstIn(_stayDistance, positions);
    return firstIn.isEmpty || positions.length == firstIn.length
        ? null
        : PositionUtils.getCenter(firstIn);
  }

  @override
  Future<bool> hasStartedMoving() {
    return Future.microtask(() async {
      if (_startedMoving != null) return true;
      if (_positions.length < 2) return false;
      Position? centerStart = cluster(_positions);
      if (centerStart == null) return false;
      _startedMoving = centerStart;
      return true;
    });
  }

  @override
  Future<double> calculateEndProbability() {
    return Future.microtask(() async {
      if (!(await hasStartedMoving())) return 0;
      DateTime last = _positions.last.timestamp;
      DateTime from = last.subtract(_stayDuration);
      if (from.isBefore(_startedMoving!.timestamp) ||
          last.difference(_startedMoving!.timestamp) < _stayDuration) return 0;
      double holdAgainProb = await PositionUtils.calculateSingleHoldProbability(
          from, _stayDuration, _stayDistance, _positions);
      return holdAgainProb;
    });
  }

  @override
  add(Position position) async {
    _positions.add(position);
  }

  @override
  int collectedDataPoints() {
    return _positions.length;
  }

  @override
  Future<Leg> get() async {
    return Future.microtask(() async {
      // Trimming positions
      List<Position> trimmedPositions = List.empty(growable: true);
      DateTime start = _positions.first.timestamp;
      if (_startedMoving != null) {
        start = _startedMoving!.timestamp;
        trimmedPositions.add(_startedMoving!);
      }

      Position? endCenter = cluster(_positions.reversed.toList());
      DateTime end =
          endCenter == null ? _positions.last.timestamp : endCenter.timestamp;

      for (int i = 0; i < _positions.length - 1; i++) {
        if (_positions[i].timestamp.isAfter(start) &&
            _positions[i].timestamp.isBefore(end)) {
          trimmedPositions.add(_positions[i]);
        }
      }
      if (endCenter != null) trimmedPositions.add(endCenter);
      _positions = trimmedPositions;

      // Calculating probability
      double maxProbability = 0;
      TransportTypeData maxData = TransportTypeData.by_foot;
      for (TransportTypeData data in TransportTypeData.values) {
        double probability = await calculateProbability(data);
        if (probability > maxProbability) {
          maxProbability = probability;
          maxData = data;
        }
      }

      // Wrapping
      return Leg.withData(maxData.getTransportType(),
          _positions.map(TrackedPoint.fromPosition).toList());
    });
  }
}
