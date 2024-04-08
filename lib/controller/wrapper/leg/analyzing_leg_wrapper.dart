import 'dart:async';

import 'package:trekko_backend/controller/utils/position_utils.dart';
import 'package:trekko_backend/controller/wrapper/leg/leg_wrapper.dart';
import 'package:trekko_backend/controller/wrapper/leg/position/transport_type_data.dart';
import 'package:trekko_backend/controller/wrapper/leg/position/weighted_transport_type_evaluator.dart';
import 'package:trekko_backend/model/position.dart';
import 'package:trekko_backend/model/trip/leg.dart';
import 'package:trekko_backend/model/trip/tracked_point.dart';
import 'package:fling_units/fling_units.dart';
import 'package:trekko_backend/model/trip/transport_type.dart';

class AnalyzingLegWrapper implements LegWrapper {
  static const Duration _stayDuration = Duration(minutes: 2);
  static Distance _stayDistance = meters(50);

  List<Position> _positions = List.empty(growable: true);
  Position? _startedMoving;

  Future<double> _calculateProbability(TransportTypeData data) {
    WeightedTransportTypeEvaluator evaluator =
        WeightedTransportTypeEvaluator(data);
    Leg leg = Leg();
    leg.trackedPoints = _positions.map(TrackedPoint.fromPosition).toList();
    return evaluator.evaluate(leg);
  }

  Future<TransportType> _calculateMaxProbability() async {
    // Calculating probability
    double maxProbability = 0;
    TransportTypeData maxData = TransportTypeData.by_foot;
    for (TransportTypeData data in TransportTypeData.values) {
      double probability = await _calculateProbability(data);
      if (probability > maxProbability) {
        maxProbability = probability;
        maxData = data;
      }
    }
    return maxData.transportType;
  }

  Position? _cluster(List<Position> positions) {
    List<Position> firstIn = PositionUtils.getFirstIn(_stayDistance, positions);
    return firstIn.isEmpty ? null : PositionUtils.getCenter(firstIn);
  }

  Future<bool> _checkStartedMoving() async {
    if (_startedMoving != null) return true;
    // Check if first and last position are at least _stayDuration apart
    if (_positions.isEmpty) return false;
    if (_positions.last.timestamp
        .isBefore(_positions.first.timestamp.add(_stayDuration))) return false;
    return PositionUtils.maxDistance(_positions) >= _stayDistance.as(meters);
  }

  @override
  Future<bool> hasStartedMoving() async {
    return _startedMoving != null;
  }

  @override
  Future<double> calculateEndProbability() {
    return Future.microtask(() async {
      if (!(await hasStartedMoving())) return 0;
      print("Calculating hold again probability");
      DateTime last = _positions.last.timestamp;
      DateTime from = last.subtract(_stayDuration);
      // Check if last point is longer than _stayDuration away from _startedMoving
      if (last.difference(_startedMoving!.timestamp) < _stayDuration) return 0;
      double holdAgainProb = await PositionUtils.calculateSingleHoldProbability(
          from, _stayDuration, _stayDistance, _positions);
      print("Hold again prob: $holdAgainProb");
      return holdAgainProb;
    });
  }

  @override
  add(Position position) async {
    _positions.add(position);

    if (_startedMoving == null && await _checkStartedMoving()) {
      Position? centerStart = _cluster(_positions);
      if (centerStart == null) throw Exception("No center start found");
      _startedMoving = centerStart;
    }
  }

  @override
  Future<Leg> get() async {
    return Future.microtask(() async {
      // Trimming positions
      List<Position> trimmedPositions = List.empty(growable: true);
      if (!(await hasStartedMoving())) throw Exception("Not started moving");
      DateTime start = _startedMoving!.timestamp;
      trimmedPositions.add(_startedMoving!);

      Position endCenter = _cluster(_positions.reversed.toList())!;
      DateTime end = endCenter.timestamp;

      for (int i = 0; i < _positions.length - 1; i++) {
        if (_positions[i].timestamp.isAfter(start) &&
            _positions[i].timestamp.isBefore(end)) {
          trimmedPositions.add(_positions[i]);
        }
      }

      trimmedPositions.add(endCenter);
      _positions = trimmedPositions;

      // Wrapping
      return Leg.withData(await _calculateMaxProbability(),
          _positions.map(TrackedPoint.fromPosition).toList());
    });
  }
}
