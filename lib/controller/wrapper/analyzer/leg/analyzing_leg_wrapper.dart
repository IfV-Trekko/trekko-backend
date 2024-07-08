import 'dart:async';

import 'package:fling_units/fling_units.dart';
import 'package:trekko_backend/controller/utils/position_utils.dart';
import 'package:trekko_backend/controller/utils/time_utils.dart';
import 'package:trekko_backend/controller/wrapper/analyzer/leg/leg_wrapper.dart';
import 'package:trekko_backend/controller/wrapper/analyzer/leg/transport/transport_type_data.dart';
import 'package:trekko_backend/controller/wrapper/analyzer/leg/transport/transport_type_data_provider.dart';
import 'package:trekko_backend/controller/wrapper/analyzer/leg/transport/transport_type_evaluator.dart';
import 'package:trekko_backend/controller/wrapper/analyzer/leg/transport/transport_type_part.dart';
import 'package:trekko_backend/controller/wrapper/analyzer/leg/transport/weighted_transport_type_evaluator.dart';
import 'package:trekko_backend/controller/wrapper/wrapper_result.dart';
import 'package:trekko_backend/model/tracking/raw_phone_data.dart';
import 'package:trekko_backend/model/trip/leg.dart';
import 'package:trekko_backend/model/trip/tracked_point.dart';

class AnalyzingLegWrapper implements LegWrapper {
  static Distance _minDistance = 50.meters;

  TransportTypeEvaluator _evaluator;

  AnalyzingLegWrapper(Iterable<RawPhoneData> initialData)
      : _evaluator = WeightedTransportTypeEvaluator(initialData.toList());

  Iterable<TransportTypePart> _smoothData(List<TransportTypePart> data) {
    TransportTypeDataProvider previous = TransportTypeData.stationary;
    TransportTypePart? firstRemove =
        data.cast<TransportTypePart?>().firstWhere((element) {
      if (element!.included.length < 2) return true;

      if (element.duration.inSeconds <
          previous.getMaximumStopTime().as(seconds)) return true;

      double distance = PositionUtils.maxDistance(element.included);
      if (element.transportType != TransportTypeData.stationary &&
          distance.meters < _minDistance)
        return true;

      previous = element.transportType;
      return false;
    }, orElse: () => null);

    if (firstRemove == null) return data;

    int indexOfRemove = data.indexOf(firstRemove);
    data.removeAt(indexOfRemove);
    if (indexOfRemove > 0 && indexOfRemove < data.length) {
      TransportTypePart before = data[indexOfRemove - 1];
      TransportTypePart after = data[indexOfRemove];

      // Connect the two parts if transport type is the same
      if (before.transportType == after.transportType) {
        TransportTypePart part = TransportTypePart(
            before.start,
            after.end,
            (before.confidence + after.confidence) / 2,
            before.transportType,
            before.included.followedBy(after.included));
        data[indexOfRemove - 1] = part;
        data.removeAt(indexOfRemove);
      }
    }
    return _smoothData(data);
  }

  bool _isTransportPartValid(TransportTypePart part) {
    // Get first TransportTypePart where the duration is longer than _minTransportUsage
    double distance = PositionUtils.distanceBetweenPoints(part.included);
    return part.transportType.getTransportType() != null &&
        part.included.length >= 2 &&
        distance.meters > _minDistance;
  }

  Future<TransportTypePart?> _calculateFirstMainTransportPart(
      Iterable<TransportTypePart> analysis) async {
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

      Iterable<TransportTypePart> data = _smoothData(result.result!);

      TransportTypePart? mainPart =
          await _calculateFirstMainTransportPart(data);

      if (mainPart == null) return invalid;

      TransportTypePart? endPart = data.cast<TransportTypePart?>().firstWhere(
          (element) => element!.end.isAfter(mainPart.end),
          orElse: () => null);

      if (endPart == null) return invalid;

      List<TrackedPoint> positionsInTime =
          mainPart.included.map(TrackedPoint.fromPosition).toList();

      Leg leg = Leg.withData(
          mainPart.transportType.getTransportType()!, positionsInTime);
      return WrapperResult(
          1, // TODO: Linear confidence growth instead of 1
          // mainPart.confidence,
          leg,
          analysisData
              .where((e) => e.getTimestamp().isAfterIncluding(mainPart.end)));
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
