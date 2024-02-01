import 'package:app_backend/controller/utils/position_utils.dart';
import 'package:app_backend/controller/wrapper/leg/leg_wrapper.dart';
import 'package:app_backend/controller/wrapper/leg/position/transport_type_data.dart';
import 'package:app_backend/controller/wrapper/leg/position/weighted_transport_type_evaluator.dart';
import 'package:app_backend/model/trip/leg.dart';
import 'package:app_backend/model/trip/tracked_point.dart';
import 'package:fling_units/fling_units.dart';
import 'package:geolocator/geolocator.dart';

class AnalyzingLegWrapper implements LegWrapper {
  static const Duration _stayDuration = Duration(minutes: 2);
  static Distance _stayDistance = meters(50);

  List<Position> _positions = List.empty(growable: true);
  DateTime? _startedMoving;

  Future<double> calculateProbability(TransportTypeData data) {
    WeightedTransportTypeEvaluator evaluator =
        WeightedTransportTypeEvaluator(data);
    return evaluator.evaluate(_positions);
  }

  @override
  Future<double> calculateEndProbability() {
    return Future.microtask(() async {
      if (_positions.isEmpty) return 0;
      if (_startedMoving == null) {
        List<Position> firstIn =
            PositionUtils.getFirstIn(_stayDistance, _positions);
        if (firstIn.last == _positions.last) return 0;
        _startedMoving = firstIn.last.timestamp;
      }

      if (_startedMoving == null) return 0;
      DateTime from = _positions.last.timestamp.subtract(_stayDuration);
      if (from.isBefore(_startedMoving!)) return 0;
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
      DateTime start = _startedMoving ?? _positions.first.timestamp;
      DateTime end =
          PositionUtils.getFirstIn(_stayDistance, _positions.reversed.toList())
              .last
              .timestamp;
      for (int i = 0; i < _positions.length - 1; i++) {
        if (_positions[i].timestamp.isAfter(start) &&
            _positions[i].timestamp.isBefore(end)) {
          trimmedPositions.add(_positions[i]);
        }
      }
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
