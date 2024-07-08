import 'package:fling_units/fling_units.dart';
import 'package:trekko_backend/controller/utils/logging.dart';
import 'package:trekko_backend/controller/utils/position_utils.dart';
import 'package:trekko_backend/controller/utils/time_utils.dart';
import 'package:trekko_backend/controller/wrapper/analyzer/leg/analyzing_leg_wrapper.dart';
import 'package:trekko_backend/controller/wrapper/analyzer/leg/leg_wrapper.dart';
import 'package:trekko_backend/controller/wrapper/analyzer/trip_wrapper.dart';
import 'package:trekko_backend/controller/wrapper/wrapper_result.dart';
import 'package:trekko_backend/model/tracking/cache/raw_phone_data_type.dart';
import 'package:trekko_backend/model/tracking/position.dart';
import 'package:trekko_backend/model/tracking/raw_phone_data.dart';
import 'package:trekko_backend/model/trip/leg.dart';
import 'package:trekko_backend/model/trip/trip.dart';

class AnalyzingTripWrapper implements TripWrapper {
  static const Duration _stayDuration = Duration(minutes: 25);
  static const Duration _analysisGranularity = Duration(minutes: 1);
  static Distance _stayDistance = meters(200);

  final List<Leg> _legs = List.empty(growable: true);
  LegWrapper _legWrapper;

  AnalyzingTripWrapper(Iterable<RawPhoneData> initialData)
      : _legWrapper = AnalyzingLegWrapper(initialData);

  Future<double> _calculateEndProbability(
      Iterable<RawPhoneData> analysisData) async {
    DateTime analysisStart = analysisData.first.getTimestamp();
    Duration analysisDuration =
        analysisData.last.getTimestamp().difference(analysisStart);
    Duration durDiff = analysisDuration - _stayDuration;
    int iterations = durDiff.inMinutes ~/ _analysisGranularity.inMinutes;

    if (iterations <= 0) return 0;

    List<double> probabilities = [];
    for (int i = 0; i < iterations; i++) {
      DateTime start = analysisStart
          .add(Duration(minutes: i * _analysisGranularity.inMinutes));
      DateTime end = start.add(_stayDuration);
      Iterable<Position> positions = analysisData
          .where((d) => d.getType() == RawPhoneDataType.position)
          .cast<Position>()
          .where((p) => p.getTimestamp().isAfter(start))
          .where((p) => p.getTimestamp().isBefore(end));

      double distance = PositionUtils.distanceBetweenPoints(positions);
      double distanceToHoldProbability = _stayDistance.as(meters) / distance;
      if (distanceToHoldProbability >= 1) {
        return 1;
      }

      probabilities.add(distanceToHoldProbability);
    }

    // Return max probability
    return probabilities
        .reduce((value, element) => value > element ? value : element);
  }

  @override
  add(Iterable<RawPhoneData> data) {
    _legWrapper.add(data);
  }

  @override
  Future<WrapperResult<Trip>> get() async {
    Iterable<RawPhoneData> analysisData = await getAnalysisData();
    if (analysisData.isEmpty) return WrapperResult(1, null, []);

    WrapperResult result;
    while ((result = await _legWrapper.get()).confidence >= 0.75) {
      if (result.result == null) {
        break;
      }

      if (!_legs.isEmpty) {
        DateTime lowerBound = _legs.last.calculateEndTime();
        DateTime upperBound = result.result.calculateStartTime();
        Iterable<RawPhoneData> dataSinceLastLeg =
            analysisData.where((d) => d.getTimestamp().isAfter(lowerBound));
        double endProbability = await _calculateEndProbability(dataSinceLastLeg
            .where((d) => d.getTimestamp().isBefore(upperBound)));
        if (endProbability > 0.90) {
          return WrapperResult(
              endProbability,
              Trip.withData(_legs),
              dataSinceLastLeg
                  .where((d) => d.getTimestamp().isAfterIncluding(upperBound)));
        }
      }

      Logging.info("Adding leg to trip ${result.result.toJson()}");
      _legs.add(result.result as Leg);
      _legWrapper = AnalyzingLegWrapper(result.unusedDataPoints);
    }

    if (_legs.isEmpty) {
      return WrapperResult(1, null, []);
    }

    DateTime upperBound = _legs.last.calculateEndTime();
    Iterable<RawPhoneData> endData =
        analysisData.where((d) => d.getTimestamp().isAfter(upperBound));
    double endProbability = await _calculateEndProbability(endData);
    return WrapperResult(endProbability, Trip.withData(_legs), endData);
  }

  @override
  Future<Iterable<RawPhoneData>> getAnalysisData() async {
    return _legs
        .expand((element) =>
            element.trackedPoints.map((e) => e.toPosition() as RawPhoneData))
        .followedBy(await _legWrapper.getAnalysisData());
  }

  @override
  Map<String, dynamic> save() {
    Map<String, dynamic> json = Map<String, dynamic>();
    json["legs"] = _legs.map((e) => e.toJson()).toList();
    json["legWrapper"] = _legWrapper.save();
    return json;
  }

  @override
  void load(Map<String, dynamic> json) {
    List<dynamic> legs = json["legs"];
    _legs.clear();
    _legs.addAll(legs.map((e) => Leg.fromJson(e)));
    _legWrapper.load(json["legWrapper"]);
  }
}
