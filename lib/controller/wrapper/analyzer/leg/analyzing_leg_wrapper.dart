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

  bool shallRemove(
      TransportTypePart element, TransportTypeDataProvider previous) {
    if (element.included.length < 2) return true;

    if (element.duration.inSeconds < previous.getMaximumStopTime().as(seconds))
      return true;

    double distance = PositionUtils.maxDistance(element.included);
    if (element.transportType != TransportTypeData.stationary &&
        distance.meters < _minDistance) return true;

    return false;
  }

  Iterable<TransportTypePart> _smoothData(Iterable<TransportTypePart> data) {
    Set<TransportTypePart> removed = Set();
    Iterable<TransportTypePart> nonRemoved =
        data.where((p) => !removed.contains(p));
    return nonRemoved.map((part) {
      while (true) {
        TransportTypePart? next =
            nonRemoved.where((next) => next.end.isAfter(part.end)).firstOrNull;

        if (next != null && shallRemove(next, part.transportType)) {
          removed.add(next);
          if (next.transportType == part.transportType) {
            // TODO: Add a time limit for connecting two parts
            part = TransportTypePart(
                part.start,
                next.end,
                (part.confidence + next.confidence) / 2,
                part.transportType,
                part.included.followedBy(next.included));
          }
        } else {
          break;
        }
      }

      return part;
    });
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
      WrapperResult<Iterable<TransportTypePart>> result =
          await _evaluator.get();
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
