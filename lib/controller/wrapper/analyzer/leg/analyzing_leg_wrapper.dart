import 'dart:async';

import 'package:trekko_backend/controller/wrapper/analyzer/leg/leg_wrapper.dart';
import 'package:trekko_backend/controller/wrapper/analyzer/leg/position/transport_type_data.dart';
import 'package:trekko_backend/controller/wrapper/analyzer/leg/position/transport_type_evaluator.dart';
import 'package:trekko_backend/controller/wrapper/analyzer/leg/position/transport_type_part.dart';
import 'package:trekko_backend/controller/wrapper/analyzer/leg/position/weighted_transport_type_evaluator.dart';
import 'package:trekko_backend/controller/wrapper/wrapper_result.dart';
import 'package:trekko_backend/model/tracking/cache/raw_phone_data_type.dart';
import 'package:trekko_backend/model/tracking/position.dart';
import 'package:trekko_backend/model/tracking/raw_phone_data.dart';
import 'package:trekko_backend/model/trip/leg.dart';
import 'package:trekko_backend/model/trip/tracked_point.dart';

class AnalyzingLegWrapper implements LegWrapper {
  static const Duration _minTransportUsage = Duration(minutes: 3);

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
      if (indexOfRemove > 0 && indexOfRemove < data.length - 1) {
        TransportTypePart before = data[indexOfRemove - 1];
        TransportTypePart after = data[indexOfRemove + 1];

        // Connect the two parts if transport type is the same
        if (before.transportType == after.transportType) {
          data[indexOfRemove - 1] =
              TransportTypePart(before.start, after.end, before.transportType);
          data.removeAt(indexOfRemove);
          data.removeAt(indexOfRemove + 1);
          return _smoothData(data);
        }
      }
    }
    return data;
  }

  TransportTypePart _calculateFirstMainTransportPart(
      Iterable<TransportTypePart> analysis) {
    // Get first TransportTypePart where the duration is longer than _minTransportUsage
    return analysis
        .where((e) => e.transportType != TransportTypeData.none)
        .firstWhere((element) => element.duration > _minTransportUsage,
            orElse: () => TransportTypePart(analysis.first.start,
                analysis.last.end, TransportTypeData.none));
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
      if (result.result == null) return WrapperResult(0, null, analysisData);

      Iterable<TransportTypePart> data = _smoothData(result.result);
      TransportTypePart mainPart = _calculateFirstMainTransportPart(data);
      TransportTypePart? endPart = data.cast<TransportTypePart?>().firstWhere(
          (element) => element!.end.isAfter(mainPart.end),
          orElse: () => null);

      if (mainPart == TransportTypeData.none || endPart == null)
        return WrapperResult(0, null, analysisData);

      List<TrackedPoint> positions = analysisData
          .where((e) => e.getType() == RawPhoneDataType.position)
          .cast<Position>()
          .where((element) => element.getTimestamp().isAfter(mainPart.start))
          .where((element) => element.getTimestamp().isBefore(mainPart.end))
          .map(TrackedPoint.fromPosition)
          .toList();

      Leg leg = Leg.withData(mainPart.transportType.transportType!, positions);
      return WrapperResult(result.confidence, leg,
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
