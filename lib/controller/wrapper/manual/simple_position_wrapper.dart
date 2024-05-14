import 'package:trekko_backend/controller/wrapper/manual/manual_trip_wrapper.dart';
import 'package:trekko_backend/model/position.dart';
import 'package:trekko_backend/model/trip/leg.dart';
import 'package:trekko_backend/model/trip/tracked_point.dart';
import 'package:trekko_backend/model/trip/transport_type.dart';
import 'package:trekko_backend/model/trip/trip.dart';

class SimplePositionWrapper implements ManualTripWrapper {
  final List<Leg> _legs = [];
  final List<Position> _positions = [];
  TransportType? type;
  bool _endOnLegEnd = false;

  @override
  Future add(Position position) async {
    _positions.add(position);

    if (_positions.length >= 2) {
      _legs.add(Leg.withData(
          type!, _positions.map((e) => TrackedPoint.fromPosition(e)).toList()));
      _positions.clear();
    }
  }

  @override
  Future<double> calculateEndProbability() async {
    return _endOnLegEnd && _positions.isEmpty ? 1 : 0;
  }

  @override
  Future<Trip> get({bool preliminary = false}) async {
    return Trip.withData(_legs)..comment = "Tracked manually";
  }

  @override
  void load(Map<String, dynamic> json) {
    _legs.clear();
    _positions.clear();

    _legs.addAll(json["legs"].map((e) => Leg.fromJson(e)).toList());
    _positions
        .addAll(json["positions"].map((e) => Position.fromJson(e)).toList());
    if (json.containsKey("transportType")) {
      type = TransportType.values[json["transportType"] as int];
    }
  }

  @override
  Map<String, dynamic> save() {
    Map<String, dynamic> json = Map<String, dynamic>();
    json["legs"] = _legs.map((e) => e.toJson()).toList();
    json["positions"] = _positions.map((e) => e.toJson()).toList();
    if (type != null) {
      json["transportType"] = type!.index;
    }
    return json;
  }

  @override
  void triggerEndOnLegEnd() {
    _endOnLegEnd = true;
  }

  @override
  void updateTransportType(TransportType type) {
    this.type = type;
  }
}
