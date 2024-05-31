import 'dart:async';

import 'package:trekko_backend/controller/utils/position_utils.dart';
import 'package:trekko_backend/controller/wrapper/analyzer/leg/leg_wrapper.dart';
import 'package:trekko_backend/controller/wrapper/analyzer/leg/position/transport_type_data.dart';
import 'package:trekko_backend/controller/wrapper/analyzer/leg/position/weighted_transport_type_evaluator.dart';
import 'package:trekko_backend/controller/wrapper/wrapper_result.dart';
import 'package:trekko_backend/model/tracking/cache/raw_phone_data_type.dart';
import 'package:trekko_backend/model/tracking/position.dart';
import 'package:trekko_backend/model/tracking/raw_phone_data.dart';
import 'package:trekko_backend/model/trip/leg.dart';
import 'package:trekko_backend/model/trip/tracked_point.dart';
import 'package:fling_units/fling_units.dart';
import 'package:trekko_backend/model/trip/transport_type.dart';

class AnalyzingLegWrapper implements LegWrapper {
  static const Duration _stayDuration = Duration(minutes: 3);
  static Distance _stayDistance = meters(50);

  List<Position> _positions;
  Position? _startedMoving;

  AnalyzingLegWrapper(this._positions);

  Future<double> _calculateProbability(
      List<Position> positions, TransportTypeData data) {
    WeightedTransportTypeEvaluator evaluator =
        WeightedTransportTypeEvaluator(data);
    Leg leg = Leg();
    leg.trackedPoints = positions.map(TrackedPoint.fromPosition).toList();
    return evaluator.evaluate(leg);
  }

  Future<TransportType> _calculateMaxProbability(
      List<Position> positions) async {
    // Calculating probability
    double maxProbability = 0;
    TransportTypeData maxData = TransportTypeData.by_foot;
    for (TransportTypeData data in TransportTypeData.values) {
      double probability = await _calculateProbability(positions, data);
      if (probability > maxProbability) {
        maxProbability = probability;
        maxData = data;
      }
    }
    return maxData.transportType;
  }

  Position? _cluster(List<Position> positions, {bool reverse = false}) {
    List<Position> firstIn = PositionUtils.getFirstIn(_stayDistance, positions);
    return firstIn.isEmpty
        ? null
        : PositionUtils.getCenter(firstIn, reverse: reverse);
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
  Future<Position?> getLegStart() async {
    return _startedMoving;
  }

  @override
  Future<double> calculateEndProbability() {
    return Future.microtask(() async {
      if (_startedMoving == null) return 0;
      DateTime last = _positions.last.timestamp;
      DateTime from = last.subtract(_stayDuration);
      // Check if last point is longer than _stayDuration away from _startedMoving
      if (last.difference(_startedMoving!.timestamp) < _stayDuration) return 0;
      return await PositionUtils.calculateSingleHoldProbability(
          from, _stayDuration, _stayDistance, _positions);
    });
  }

  @override
  add(RawPhoneData position) async {
    if (position.getType() != RawPhoneDataType.position) return; // TODO: Analyze other types

    if (_positions.isNotEmpty &&
        (position as Position).timestamp.isBefore(_positions.last.timestamp)) {
      throw Exception(
          "Positions must be added in chronological order. Last timestamp: ${_positions.last.timestamp}, new timestamp: ${position.timestamp}");
    }

    _positions.add(position as Position);
    if (_startedMoving == null && await _checkStartedMoving()) {
      Position? centerStart = _cluster(_positions);
      if (centerStart == null) throw Exception("No center start found");
      _startedMoving = centerStart;
    }
  }

  @override
  Future<WrapperResult<Leg>> get({bool preliminary = false}) async {
    return Future.microtask(() async {
      if (preliminary) {

        return WrapperResult(Leg.withData(await _calculateMaxProbability(_positions),
            _positions.map(TrackedPoint.fromPosition).toList()),
            []
        );
      }

      if (_startedMoving == null) throw Exception("Not started moving");

      // Trimming positions
      List<Position> trimmedPositions = List.empty(growable: true);
      DateTime start = _startedMoving!.timestamp;
      trimmedPositions.add(_startedMoving!);

      Position endCenter = _cluster(_positions.reversed
          .where((element) => element.timestamp.isAfter(start))
          .toList())!;
      DateTime end = endCenter.timestamp;
      for (int i = 0; i < _positions.length - 1; i++) {
        if (_positions[i].timestamp.isAfter(start) &&
            _positions[i].timestamp.isBefore(end)) {
          trimmedPositions.add(_positions[i]);
        }
      }

      trimmedPositions.add(endCenter);
      return WrapperResult(Leg.withData(await _calculateMaxProbability(trimmedPositions),
          trimmedPositions.map(TrackedPoint.fromPosition).toList()),
          [] // todo return leg and not used data points
      );
    });
  }

  @override
  Map<String, dynamic> save() {
    Map<String, dynamic> json = Map<String, dynamic>();
    json["positions"] = _positions.map((e) => e.toJson()).toList();
    if (_startedMoving != null)
      json["startedMoving"] = _startedMoving!.toJson();
    return json;
  }

  @override
  void load(Map<String, dynamic> json) {
    List<dynamic> positions = json["positions"];
    _positions.clear();
    _positions.addAll(positions.map((e) => Position.fromJson(e)));
    if (json.containsKey("startedMoving")) {
      _startedMoving = Position.fromJson(json["startedMoving"]);
    }
  }
}
