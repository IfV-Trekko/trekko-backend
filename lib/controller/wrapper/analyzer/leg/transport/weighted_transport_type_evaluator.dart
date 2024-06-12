import 'package:flutter_activity_recognition/flutter_activity_recognition.dart';
import 'package:trekko_backend/controller/utils/logging.dart';
import 'package:trekko_backend/controller/utils/time_utils.dart';
import 'package:trekko_backend/controller/wrapper/analyzer/leg/transport/transport_type_data.dart';
import 'package:trekko_backend/controller/wrapper/analyzer/leg/transport/transport_type_evaluator.dart';
import 'package:trekko_backend/controller/wrapper/analyzer/leg/transport/transport_type_part.dart';
import 'package:trekko_backend/controller/wrapper/wrapper_result.dart';
import 'package:trekko_backend/model/tracking/activity_data.dart';
import 'package:trekko_backend/model/tracking/cache/raw_phone_data_type.dart';
import 'package:trekko_backend/model/tracking/position.dart';
import 'package:trekko_backend/model/tracking/raw_phone_data.dart';

class WeightedTransportTypeEvaluator implements TransportTypeEvaluator {
  List<RawPhoneData> _data;

  WeightedTransportTypeEvaluator(this._data);

  double confidenceFromActivity(ActivityData data) {
    return data.confidence == ActivityConfidence.MEDIUM ? 0.5 : 1;
  }

  DateTime getLatestTimestamp() {
    return _data.last.getTimestamp();
  }

  double avg(Iterable<double> list) {
    return list.isEmpty
        ? 0
        : list.reduce((value, element) => value + element) / list.length;
  }

  List<List<ActivityData>> joinDataOnType() {
    List<ActivityData> activities = _data
        .where((d) => d.getType() == RawPhoneDataType.activity)
        .cast<ActivityData>()
        .toList();

    List<List<ActivityData>> joinedData = [];
    List<ActivityData> currentType = [];
    for (ActivityData data in activities) {
      if (currentType.isEmpty) {
        currentType.add(data);
      } else {
        if (currentType.last.activity == data.activity) {
          currentType.add(data);
        } else {
          joinedData.add(currentType);
          currentType = [data];
        }
      }
    }

    if (!currentType.isEmpty) {
      joinedData.add(currentType);
    }

    return joinedData;
  }

  @override
  add(Iterable<RawPhoneData> data) {
    for (RawPhoneData phoneData in data) {
      // TODO: Move this into a filter class?
      if (phoneData.getType() == RawPhoneDataType.activity) {
        ActivityData activity = phoneData as ActivityData;
        if (activity.confidence == ActivityConfidence.LOW ||
            activity.activity == ActivityType.UNKNOWN) {
          continue;
        }
      }

      // Check if data is in order
      if (_data.isNotEmpty &&
          phoneData.getTimestamp().isBefore(_data.last.getTimestamp())) {
        Logging.error(
            "Data is not in order: ${phoneData.getTimestamp()} is before ${_data.last.getTimestamp()}");
        continue;
      }

      _data.add(phoneData);
    }
  }

  @override
  Future<WrapperResult<List<TransportTypePart>>> get() async {
    List<List<ActivityData>> joinedData = joinDataOnType();

    List<TransportTypePart> analysis = [];
    Iterable<Position> positions = _data
        .where((d) => d.getType() == RawPhoneDataType.position)
        .cast<Position>();
    for (int i = 0; i < joinedData.length; i++) {
      List<ActivityData> activities = joinedData[i];
      DateTime start = activities.first.getTimestamp();
      DateTime end = i == joinedData.length - 1
          ? getLatestTimestamp()
          : joinedData[i + 1].first.getTimestamp();
      Iterable<Position> partPos =
          positions.where((p) => p.timestamp.isInInclusive(start, end));

      ActivityType type = activities.first.activity;
      double confidence = avg(activities.map((e) => confidenceFromActivity(e)));

      TransportTypeData data;
      if (type == ActivityType.IN_VEHICLE) {
        // TODO: Further analysis to check if car or publicTransport
        data = TransportTypeData.car;
      } else {
        data = TransportTypeData.fromActivityType(type)!;
      }

      analysis.add(TransportTypePart(start, end, confidence, data, partPos));
    }

    double conf =
        analysis.length == 0 ? 1 : avg(analysis.map((e) => e.confidence));
    return WrapperResult(conf, analysis, []);
  }

  @override
  Future<Iterable<RawPhoneData>> getAnalysisData() {
    return Future.value(_data);
  }

  @override
  Map<String, dynamic> save() {
    Map<String, dynamic> json = Map<String, dynamic>();
    json["data"] = _data.map((e) => e.toJson()).toList();
    return json;
  }

  @override
  void load(Map<String, dynamic> json) {
    List<dynamic> positions = json["data"];
    _data.clear();
    _data.addAll(positions.map((e) => RawPhoneDataType.parseData(e)));
  }
}
