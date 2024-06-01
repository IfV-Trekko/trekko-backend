import 'dart:async';

import 'package:fling_units/fling_units.dart';
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
import 'package:trekko_backend/model/trip/transport_type.dart';

class AnalyzingLegWrapper implements LegWrapper {
  static const Duration _stayDuration = Duration(minutes: 3);
  static Distance _stayDistance = meters(50);

  List<RawPhoneData> _data;
  Position? _startedMoving;

  AnalyzingLegWrapper(this._data);

  List<Position> _getPositions() {
    return _data
        .where((element) => element.getType() == RawPhoneDataType.position)
        .map((e) => e as Position)
        .toList();
  }

  Future<double> _calculateProbability(
      List<RawPhoneData> data, TransportTypeData dataType) {
    WeightedTransportTypeEvaluator evaluator =
        WeightedTransportTypeEvaluator(dataType);
    return evaluator.evaluate(data);
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
    List<Position> positions = _getPositions();
    if (positions.isEmpty) return false;
    if (positions.last.timestamp
        .isBefore(positions.first.timestamp.add(_stayDuration))) return false;
    return PositionUtils.maxDistance(positions) >= _stayDistance.as(meters);
  }

  @override
  Future<Position?> getLegStart() async {
    return _startedMoving;
  }

  @override
  Future<double> calculateEndProbability() {
    return Future.microtask(() async {
      if (_startedMoving == null) return 0;
      List<Position> positions = _getPositions();
      DateTime last = positions.last.timestamp;
      DateTime from = last.subtract(_stayDuration);
      // Check if last point is longer than _stayDuration away from _startedMoving
      if (last.difference(_startedMoving!.timestamp) < _stayDuration) return 0;
      return await PositionUtils.calculateSingleHoldProbability(
          from, _stayDuration, _stayDistance, positions);
    });
  }

  @override
  add(RawPhoneData data) async {
    if (_data.isNotEmpty &&
        (data as Position).timestamp.isBefore(_data.last.getTimestamp())) {
      throw Exception(
          "Positions must be added in chronological order. Last timestamp: ${_data.last.getTimestamp()}, new timestamp: ${data.timestamp}");
    }

    _data.add(data);
    if (_startedMoving == null && await _checkStartedMoving()) {
      Position? centerStart = _cluster(_getPositions());
      if (centerStart == null) throw Exception("No center start found");
      _startedMoving = centerStart;
    }
  }

  @override
  Future<WrapperResult<Leg>> get({bool preliminary = false}) async {
    return Future.microtask(() async {
      List<Position> positions = _getPositions();

      if (preliminary) {
        return WrapperResult(
            Leg.withData(await _calculateMaxProbability(positions),
                positions.map(TrackedPoint.fromPosition).toList()),
            []);
      }

      if (_startedMoving == null) throw Exception("Not started moving");

      // Trimming positions
      List<Position> trimmedPositions = List.empty(growable: true);
      DateTime start = _startedMoving!.timestamp;
      trimmedPositions.add(_startedMoving!);

      Position endCenter = _cluster(positions.reversed
          .where((element) => element.timestamp.isAfter(start))
          .toList())!;
      DateTime end = endCenter.timestamp;
      for (int i = 0; i < positions.length - 1; i++) {
        if (positions[i].timestamp.isAfter(start) &&
            positions[i].timestamp.isBefore(end)) {
          trimmedPositions.add(positions[i]);
        }
      }

      trimmedPositions.add(endCenter);
      return WrapperResult(
          Leg.withData(await _calculateMaxProbability(trimmedPositions),
              trimmedPositions.map(TrackedPoint.fromPosition).toList()),
          _data.where((element) => element.getTimestamp().isAfter(end)));
    });
  }

  @override
  Map<String, dynamic> save() {
    Map<String, dynamic> json = Map<String, dynamic>();
    json["data"] = _data.map((e) => e.toJson()).toList();
    if (_startedMoving != null)
      json["startedMoving"] = _startedMoving!.toJson();
    return json;
  }

  @override
  void load(Map<String, dynamic> json) {
    List<dynamic> positions = json["positions"];
    _data.clear();
    _data.addAll(positions.map((e) => RawPhoneDataType.parseData(e)));
    if (json.containsKey("startedMoving")) {
      _startedMoving = Position.fromJson(json["startedMoving"]);
    }
  }
}
