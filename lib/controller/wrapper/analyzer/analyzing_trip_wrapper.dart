import 'package:trekko_backend/controller/utils/logging.dart';
import 'package:trekko_backend/controller/utils/position_utils.dart';
import 'package:trekko_backend/controller/wrapper/analyzer/leg/analyzing_leg_wrapper.dart';
import 'package:trekko_backend/controller/wrapper/analyzer/leg/leg_wrapper.dart';
import 'package:trekko_backend/controller/wrapper/trip_wrapper.dart';
import 'package:trekko_backend/model/position.dart';
import 'package:trekko_backend/model/trip/leg.dart';
import 'package:trekko_backend/model/trip/trip.dart';
import 'package:fling_units/fling_units.dart';

class AnalyzingTripWrapper implements TripWrapper {
  static const Duration _stayDuration = Duration(minutes: 25);
  static Distance _stayDistance = meters(200);

  final List<Leg> _legs = List.empty(growable: true);
  LegWrapper _legWrapper = AnalyzingLegWrapper();
  DateTime? newestTimestamp;

  AnalyzingTripWrapper();

  List<Position> _getPositionsInOrder() {
    return _legs
        .expand((element) => element.trackedPoints)
        .map((e) => e.toPosition())
        .toList();
  }

  @override
  Future<double> calculateEndProbability() {
    return Future.microtask(() async {
      if (_legs.isEmpty || newestTimestamp == null) return 0;

      DateTime oldestLegStart = _legs.first.calculateStartTime();
      if (newestTimestamp!.difference(oldestLegStart) < _stayDuration) return 0;

      Position? currentLegStart = await _legWrapper.getLegStart();
      if (currentLegStart != null) return 0;

      List<Position> positionsInOrder = _getPositionsInOrder();
      return PositionUtils.calculateSingleHoldProbability(
          newestTimestamp!.subtract(_stayDuration),
          _stayDuration,
          _stayDistance,
          positionsInOrder);
    });
  }

  @override
  Future add(Position position) async {
    if (newestTimestamp != null &&
        position.timestamp.isBefore(newestTimestamp!))
      throw Exception(
          "Positions must be added in chronological order. Newest timestamp: $newestTimestamp, new timestamp: ${position.timestamp}");

    newestTimestamp = position.timestamp;
    await _legWrapper.add(position);
    double probability = await _legWrapper.calculateEndProbability();
    if (probability > 0.95) {
      Logging.info("Leg finished at ${position.timestamp.toIso8601String()}");
      _legs.add(await _legWrapper.get());
      _legWrapper = AnalyzingLegWrapper();
    }
  }

  @override
  Future<Trip> get({bool preliminary = false}) async {
    List<Leg> legs = List.from(_legs);
    if (preliminary) {
      Leg lastLeg = await _legWrapper.get(preliminary: true);
      legs.add(lastLeg);
    }
    return Trip.withData(legs);
  }

  @override
  Map<String, dynamic> save() {
    Map<String, dynamic> json = Map<String, dynamic>();
    json["legs"] = _legs.map((e) => e.toJson()).toList();
    json["newestTimestamp"] = newestTimestamp?.toIso8601String();
    json["legWrapper"] = _legWrapper.save();
    return json;
  }

  @override
  void load(Map<String, dynamic> json) {
    _legs.clear();

    List<dynamic> legs = json["legs"];
    _legs.addAll(legs.map((e) => Leg.fromJson(e)));

    newestTimestamp = json["newestTimestamp"] == null
        ? null
        : DateTime.parse(json["newestTimestamp"]);
    _legWrapper.load(json["legWrapper"]);
  }
}
