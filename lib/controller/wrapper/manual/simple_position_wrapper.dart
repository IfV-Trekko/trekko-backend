import 'package:trekko_backend/controller/wrapper/manual/manual_trip_wrapper.dart';
import 'package:trekko_backend/model/position.dart';
import 'package:trekko_backend/model/trip/leg.dart';
import 'package:trekko_backend/model/trip/trip.dart';

class SimplePositionWrapper implements ManualTripWrapper {
  final List<Leg> _legs = [];
  final List<Position> _positions = [];
  bool _endOnLegEnd = false;

  @override
  Future add(Position position) async {
    _positions.add(position);
  }

  @override
  Future<double> calculateEndProbability() async {
    return _endOnLegEnd && _positions.isEmpty ? 1 : 0;
  }

  @override
  Future<Trip> get({bool preliminary = false}) async {
    return Trip.withData(_legs);
  }

  @override
  void load(Map<String, dynamic> json) {
    _legs.clear();
    _positions.clear();

    _legs.addAll(json["legs"].map((e) => Leg.fromJson(e)).toList());
    _positions
        .addAll(json["positions"].map((e) => Position.fromJson(e)).toList());
  }

  @override
  Map<String, dynamic> save() {
    Map<String, dynamic> json = Map<String, dynamic>();
    json["legs"] = _legs.map((e) => e.toJson()).toList();
    json["positions"] = _positions.map((e) => e.toJson()).toList();
    return json;
  }

  @override
  void triggerEndOnLegEnd() {
    _endOnLegEnd = true;
  }
}
