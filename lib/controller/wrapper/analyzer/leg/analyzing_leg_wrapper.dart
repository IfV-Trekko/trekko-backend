import 'dart:async';

import 'package:fling_units/fling_units.dart';
import 'package:trekko_backend/controller/utils/position_utils.dart';
import 'package:trekko_backend/controller/wrapper/analyzer/leg/leg_wrapper.dart';
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

  Iterable<TransportTypePart> _smoothData(List<TransportTypePart> data) {
    TransportTypePart? firstRemove = data.cast<TransportTypePart?>().firstWhere(
            (element) =>
        element!.duration.inSeconds <
            element.transportType.maximumHoldTimeSeconds,
        orElse: () => null);

    if (firstRemove != null) {
      int indexOfRemove = data.indexOf(firstRemove);
      data.removeAt(indexOfRemove);
      if (indexOfRemove > 0 && indexOfRemove < data.length) {
        TransportTypePart before = data[indexOfRemove - 1];
        TransportTypePart after = data[indexOfRemove];

        // Connect the two parts if transport type is the same
        if (before.transportType == after.transportType) {
          data[indexOfRemove - 1] = TransportTypePart(before.start, after.end,
              (before.confidence + after.confidence) / 2, before.transportType);
          data.removeAt(indexOfRemove);
        }
      }
      return _smoothData(data);
    }
    return data;
  }

  bool _isTransportPartValid(TransportTypePart part, List<Position> positions) {
    Iterable<Position> positionsInTime = positions
        .where((e) => e.getTimestamp().isAfter(part.start))
        .where((e) => e.getTimestamp().isBefore(part.end));
    // Get first TransportTypePart where the duration is longer than _minTransportUsage
    double distance = PositionUtils.distanceBetweenPoints(positionsInTime);
    return part.transportType != TransportTypeData.stationary &&
        positionsInTime.length >= 2 &&
        part.duration > _minTransportUsage &&
        distance > _minDistance.as(meters);
  }

  Future<TransportTypePart?> _calculateFirstMainTransportPart(
      Iterable<TransportTypePart> analysis) async {
    List<Position> positions = (await getAnalysisData())
        .where((e) => e.getType() == RawPhoneDataType.position)
        .cast<Position>()
        .toList();
    return analysis
        .where((e) => _isTransportPartValid(e, positions))
        .firstOrNull;
  }

  @override
  add(Iterable<RawPhoneData> data) {
    _evaluator.add(data);
  }

  @override
  Future<WrapperResult<Leg>> get() async {
    return Future.microtask(() async {
      WrapperResult result = await _evaluator.get();
      List<RawPhoneData> analysisData = (await this.getAnalysisData()).toList();
      WrapperResult<Leg> invalid = WrapperResult(0, null, []);

      if (result.result == null) return invalid;

      Iterable<TransportTypePart> data = _smoothData(result.result);
      TransportTypePart? mainPart =
      await _calculateFirstMainTransportPart(data);

      if (mainPart == null) return invalid;

      TransportTypePart? endPart = data.cast<TransportTypePart?>().firstWhere(
              (element) => element!.end.isAfter(mainPart.end),
          orElse: () => null);

      if (endPart == null) return invalid;

      List<TrackedPoint> positions = analysisData
          .where((e) => e.getType() == RawPhoneDataType.position)
          .cast<Position>()
          .where((element) => element.getTimestamp().isAfter(mainPart.start))
          .where((element) => element.getTimestamp().isBefore(mainPart.end))
          .map(TrackedPoint.fromPosition)
          .toList();

      Leg leg = Leg.withData(mainPart.transportType.transportType!, positions);
      return WrapperResult(
          1, // TODO: Linear confidence growth instead of 1
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
