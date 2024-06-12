import 'dart:async';

import 'package:fling_units/fling_units.dart';
import 'package:trekko_backend/controller/utils/position_utils.dart';
import 'package:trekko_backend/controller/utils/time_utils.dart';
import 'package:trekko_backend/controller/wrapper/analyzer/leg/leg_wrapper.dart';
import 'package:trekko_backend/controller/wrapper/analyzer/leg/p_transport_type_part.dart';
import 'package:trekko_backend/controller/wrapper/analyzer/leg/transport/transport_type_data.dart';
import 'package:trekko_backend/controller/wrapper/analyzer/leg/transport/transport_type_evaluator.dart';
import 'package:trekko_backend/controller/wrapper/analyzer/leg/transport/transport_type_part.dart';
import 'package:trekko_backend/controller/wrapper/analyzer/leg/transport/weighted_transport_type_evaluator.dart';
import 'package:trekko_backend/controller/wrapper/wrapper_result.dart';
import 'package:trekko_backend/model/tracking/cache/raw_phone_data_type.dart';
import 'package:trekko_backend/model/tracking/position.dart';
import 'package:trekko_backend/model/tracking/raw_phone_data.dart';
import 'package:trekko_backend/model/trip/leg.dart';
import 'package:trekko_backend/model/trip/tracked_point.dart';

class AnalyzingLegWrapper implements LegWrapper {
  static const Duration _minTransportUsage = Duration(minutes: 3);
  static Distance _minDistance = 50.meters;

  TransportTypeEvaluator _evaluator;

  AnalyzingLegWrapper(Iterable<RawPhoneData> initialData)
      : _evaluator = WeightedTransportTypeEvaluator(initialData.toList());

  Iterable<PTransportTypePart> _getPositions(
      Iterable<TransportTypePart> parts, Iterable<Position> positions) {
    return parts.map((p) => PTransportTypePart(p,
        positions.where((pos) => pos.timestamp.isInInclusive(p.start, p.end))));
  }

  Iterable<PTransportTypePart> _smoothData(List<PTransportTypePart> data) {
    PTransportTypePart? firstRemove = data
        .cast<PTransportTypePart?>()
        .firstWhere(
            (element) =>
                element!.duration.inSeconds <
                    element.transportType.maximumHoldTimeSeconds &&
                PositionUtils.maxDistance(element.included) <
                    _minDistance.as(meters),
            orElse: () => null);

    if (firstRemove == null) return data;

    int indexOfRemove = data.indexOf(firstRemove);
    data.removeAt(indexOfRemove);
    if (indexOfRemove > 0 && indexOfRemove < data.length) {
      PTransportTypePart before = data[indexOfRemove - 1];
      PTransportTypePart after = data[indexOfRemove];

      // Connect the two parts if transport type is the same
      if (before.transportType == after.transportType) {
        TransportTypePart part = TransportTypePart(before.start, after.end,
            (before.confidence + after.confidence) / 2, before.transportType);
        data[indexOfRemove - 1] = PTransportTypePart(
            part, before.included.followedBy(after.included));
        data.removeAt(indexOfRemove);
      }
    }
    return _smoothData(data);
  }

  bool _isTransportPartValid(PTransportTypePart part) {
    // Get first TransportTypePart where the duration is longer than _minTransportUsage
    double distance = PositionUtils.distanceBetweenPoints(part.included);
    return part.transportType != TransportTypeData.stationary &&
        part.included.length >= 2 &&
        part.duration > _minTransportUsage &&
        distance > _minDistance.as(meters);
  }

  Future<PTransportTypePart?> _calculateFirstMainTransportPart(
      Iterable<PTransportTypePart> analysis) async {
    return analysis.where(_isTransportPartValid).firstOrNull;
  }

  @override
  add(Iterable<RawPhoneData> data) {
    _evaluator.add(data);
  }

  @override
  Future<WrapperResult<Leg>> get() async {
    return Future.microtask(() async {
      WrapperResult<List<TransportTypePart>> result = await _evaluator.get();
      List<RawPhoneData> analysisData = (await this.getAnalysisData()).toList();
      WrapperResult<Leg> invalid = WrapperResult(result.confidence, null, []);

      if (result.result == null) return invalid;

      Iterable<Position> positions = analysisData
          .where((e) => e.getType() == RawPhoneDataType.position)
          .cast<Position>();

      Iterable<PTransportTypePart> data =
          _smoothData(_getPositions(result.result!, positions).toList());

      PTransportTypePart? mainPart =
          await _calculateFirstMainTransportPart(data);

      if (mainPart == null) return invalid;

      PTransportTypePart? endPart = data.cast<PTransportTypePart?>().firstWhere(
          (element) => element!.end.isAfter(mainPart.end),
          orElse: () => null);

      if (endPart == null) return invalid;

      List<TrackedPoint> positionsInTime =
          mainPart.included.map(TrackedPoint.fromPosition).toList();

      Leg leg =
          Leg.withData(mainPart.transportType.transportType!, positionsInTime);
      return WrapperResult(
          1, // TODO: Linear confidence growth instead of 1
          // mainPart.confidence,
          leg,
          analysisData.where((e) => e.getTimestamp().isAfter(mainPart.end)));
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
