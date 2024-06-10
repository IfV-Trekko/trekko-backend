import 'package:fling_units/fling_units.dart';
import 'package:trekko_backend/controller/utils/logging.dart';
import 'package:trekko_backend/controller/utils/position_utils.dart';
import 'package:trekko_backend/controller/wrapper/analyzer/leg/analyzing_leg_wrapper.dart';
import 'package:trekko_backend/controller/wrapper/analyzer/leg/leg_wrapper.dart';
import 'package:trekko_backend/controller/wrapper/analyzer/trip_wrapper.dart';
import 'package:trekko_backend/controller/wrapper/wrapper_result.dart';
import 'package:trekko_backend/model/tracking/position.dart';
import 'package:trekko_backend/model/tracking/raw_phone_data.dart';
import 'package:trekko_backend/model/trip/leg.dart';
import 'package:trekko_backend/model/trip/trip.dart';

class AnalyzingTripWrapper implements TripWrapper {
  static const Duration _stayDuration = Duration(minutes: 25);
  static Distance _stayDistance = meters(200);

  final List<Leg> _legs = List.empty(growable: true);
  LegWrapper _legWrapper;

  AnalyzingTripWrapper(Iterable<RawPhoneData> initialData)
      : _legWrapper = AnalyzingLegWrapper(initialData);

  List<Position> _getPositionsInOrder() {
    return _legs
        .expand((element) => element.trackedPoints)
        .map((e) => e.toPosition())
        .toList();
  }

  Future<WrapperResult> _takeResults(List<Leg> legs) async {
    WrapperResult newestResult = await _legWrapper.get();
    if (newestResult.result != null && newestResult.confidence > 0.95) {
      Leg resultLeg = newestResult.result!;
      Logging.info(
          "Leg finished at ${resultLeg.calculateEndTime().toIso8601String()}");
      legs.add(resultLeg);
      _legWrapper = AnalyzingLegWrapper(newestResult.unusedDataPoints.toList());
      return await _takeResults(legs);
    }

    return newestResult;
  }

  Future<double> _calculateEndProbability(WrapperResult legResult) {
    return Future.microtask(() async {
      Iterable<RawPhoneData> analysisData = await getAnalysisData();
      DateTime? newestTimestamp =
          analysisData.isEmpty ? null : analysisData.last.getTimestamp();
      if (_legs.isEmpty || newestTimestamp == null) return 0;

      DateTime oldestLegStart = _legs.last.calculateEndTime();
      if (newestTimestamp.difference(oldestLegStart) < _stayDuration) return 0;

      if (legResult.confidence > 0.4 && legResult.result != null) return 0;

      List<Position> positionsInOrder = _getPositionsInOrder();
      return PositionUtils.calculateSingleHoldProbability(
          newestTimestamp.subtract(_stayDuration),
          _stayDuration,
          _stayDistance,
          positionsInOrder);
    });
  }

  @override
  add(Iterable<RawPhoneData> data) {
    _legWrapper.add(data);
  }

  @override
  Future<WrapperResult<Trip>> get({bool preliminary = false}) async {
    List<Leg> legs = List.from(_legs, growable: true);
    WrapperResult newestResult = await _takeResults(legs);
    double endProbability = await _calculateEndProbability(newestResult);
    return WrapperResult(
        endProbability * newestResult.confidence,
        Trip.withData(legs),
        newestResult.unusedDataPoints.toList()); // TODO: Filter and buffer
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
    _legs.clear();

    List<dynamic> legs = json["legs"];
    _legs.addAll(legs.map((e) => Leg.fromJson(e)));
    _legWrapper.load(json["legWrapper"]);
  }
}
