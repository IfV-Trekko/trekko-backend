import 'package:trekko_backend/controller/utils/position_utils.dart';
import 'package:trekko_backend/controller/wrapper/manual/manual_trip_wrapper.dart';
import 'package:trekko_backend/controller/wrapper/wrapper_result.dart';
import 'package:trekko_backend/model/tracking/cache/raw_phone_data_type.dart';
import 'package:trekko_backend/model/tracking/position.dart';
import 'package:trekko_backend/model/tracking/raw_phone_data.dart';
import 'package:trekko_backend/model/trip/leg.dart';
import 'package:trekko_backend/model/trip/tracked_point.dart';
import 'package:trekko_backend/model/trip/transport_type.dart';
import 'package:trekko_backend/model/trip/trip.dart';

class SimplePositionWrapper implements ManualTripWrapper {
  final List<Leg> _legs = [];
  final List<Position> _positions = [];
  TransportType? _type;
  TransportType? _nextType;
  bool _endSoon = false;

  @override
  Future add(RawPhoneData position) async {
    if (this._type == null || position.getType() != RawPhoneDataType.position)
      return;

    _positions.add(position as Position);
    if (_nextType != null &&
        _positions.length > 1 &&
        PositionUtils.distanceBetweenPoints(_positions) > 0) {
      _legs.add(Leg.withData(_type!,
          _positions.map((e) => TrackedPoint.fromPosition(e)).toList()));
      _positions.clear();
      _type = _nextType;
      _nextType = null;
    }
  }

  @override
  Future<double> calculateEndProbability() async {
    return _endSoon ? 1 : 0;
  }

  @override
  Future<WrapperResult<Trip>> get({bool preliminary = false}) async {
    return WrapperResult(
        Trip.withData(_legs)..comment = "Tracked manually", []);
  }

  @override
  void load(Map<String, dynamic> json) {
    _legs.clear();
    _positions.clear();

    List<dynamic> legs = json["legs"];
    _legs.addAll(legs.map((e) => Leg.fromJson(e)));

    List<dynamic> positions = json["positions"];
    _positions.addAll(positions.map((e) => Position.fromJson(e)).toList());
    if (json.containsKey("transportType")) {
      _type = TransportType.values[json["transportType"] as int];
    }
  }

  @override
  Map<String, dynamic> save() {
    Map<String, dynamic> json = Map<String, dynamic>();
    json["legs"] = _legs.map((e) => e.toJson()).toList();
    json["positions"] = _positions.map((e) => e.toJson()).toList();
    if (_type != null) {
      json["transportType"] = _type!.index;
    }
    return json;
  }

  @override
  void triggerEnd() {
    _endSoon = true;
    _nextType = _type;
  }

  @override
  TransportType? getTransportType() {
    return this._type;
  }

  @override
  void triggerStartLeg(TransportType type) {
    if (this._type == null) {
      this._type = type;
    } else {
      this._nextType = type;
    }
  }
}
