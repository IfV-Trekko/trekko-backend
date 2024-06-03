import 'dart:async';

import 'package:fling_units/fling_units.dart';
import 'package:trekko_backend/controller/utils/position_utils.dart';
import 'package:trekko_backend/controller/wrapper/analyzer/leg/leg_wrapper.dart';
import 'package:trekko_backend/controller/wrapper/analyzer/leg/position/transport_type_evaluator.dart';
import 'package:trekko_backend/controller/wrapper/analyzer/leg/position/weighted_transport_type_evaluator.dart';
import 'package:trekko_backend/controller/wrapper/wrapper_result.dart';
import 'package:trekko_backend/model/tracking/cache/raw_phone_data_type.dart';
import 'package:trekko_backend/model/tracking/position.dart';
import 'package:trekko_backend/model/tracking/raw_phone_data.dart';
import 'package:trekko_backend/model/trip/leg.dart';

class AnalyzingLegWrapper implements LegWrapper {
  static const Duration _stayDuration = Duration(minutes: 3);
  static Distance _stayDistance = meters(50);

  TransportTypeEvaluator _evaluator;

  AnalyzingLegWrapper(Iterable<RawPhoneData> initialData)
      : _evaluator = WeightedTransportTypeEvaluator(initialData.toList());

  Future<Iterable<Position>> _getAnalysisPositions() async {
    return (await _evaluator.getAnalysisData())
        .where((element) => element.getType() == RawPhoneDataType.position)
        .cast<Position>();
  }

  Future<double> _calculateEndProbability(DateTime? startedMoving) {
    return Future.microtask(() async {
      if (startedMoving == null) return 0;
      Iterable<Position> positions = await _getAnalysisPositions();
      DateTime last = positions.last.timestamp;
      DateTime from = last.subtract(_stayDuration);
      // Check if last point is longer than _stayDuration away from _startedMoving
      if (last.difference(startedMoving) < _stayDuration) return 0;
      return await PositionUtils.calculateSingleHoldProbability(
          from, _stayDuration, _stayDistance, positions);
    });
  }

  @override
  add(Iterable<RawPhoneData> data) async {
    _evaluator.add(data);
  }

  @override
  Future<WrapperResult<Leg>> get() async {
    return Future.microtask(() async {
      // TODO: Analyse transport type, if transport type analyze is confident calculate end probability and return
      return WrapperResult(await _calculateEndProbability(null), null,
          await this._evaluator.getAnalysisData());
    });
  }

  @override
  Future<Iterable<RawPhoneData>> getAnalysisData() {
    return _evaluator.getAnalysisData();
  }

  @override
  Map<String, dynamic> save() {
    Map<String, dynamic> json = Map<String, dynamic>();
    json["evaluator"] = _evaluator.save();
    return json;
  }

  @override
  void load(Map<String, dynamic> json) {
    _evaluator.load(json["evaluator"]);
  }
}
