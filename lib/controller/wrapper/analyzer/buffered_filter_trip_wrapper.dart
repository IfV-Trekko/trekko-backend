import 'package:trekko_backend/controller/utils/position_utils.dart';
import 'package:trekko_backend/controller/wrapper/analyzer/analyzing_trip_wrapper.dart';
import 'package:trekko_backend/controller/wrapper/trip_wrapper.dart';
import 'package:trekko_backend/model/tracking/position.dart';
import 'package:trekko_backend/model/tracking/raw_phone_data.dart';
import 'package:trekko_backend/model/trip/trip.dart';

import '../wrapper_result.dart';

class BufferedFilterTripWrapper implements TripWrapper {
  static const buffer_size = 2;
  static const max_rejected = 3;
  static const tolerance = 50;

  final TripWrapper _tripWrapper;
  final List<Position> _buffer = List.empty(growable: true);
  final List<Position> _rejected = List.empty(growable: true);

  BufferedFilterTripWrapper.withBuilder(this._tripWrapper);

  BufferedFilterTripWrapper() : _tripWrapper = AnalyzingTripWrapper([]);

  double averageDistance() {
    double sum = 0;
    for (int i = 0; i < _buffer.length - 1; i++) {
      sum += PositionUtils.distanceBetween(_buffer[i], _buffer[i + 1]);
    }
    return sum / _buffer.length;
  }

  bool isValidNewPosition(Position newPosition) {
    if (_buffer.length < 2) {
      return true;
    }

    Position lastPosition = _buffer.last;

    double distance = PositionUtils.distanceBetween(lastPosition, newPosition);
    double averageDistance = this.averageDistance();
    double sub = (distance - averageDistance).abs();

    // If distance is more than tolerance meters off, we assume the GPS failed
    return sub < tolerance;
  }

  @override
  Future<void> add(RawPhoneData data) async {
    // Buffer positions and add them to the trip wrapper when the buffer is full
    // Throw away positions if they are off pattern, so the gps probably failed

    if (_rejected.length > max_rejected) {
      // Apparently the buffered positions are off pattern, so we throw away the whole buffer and add the rejected positions
      _buffer.clear();
      for (int i = 0; i < _rejected.length - 1; i++) {
        await _tripWrapper.add(_rejected[i]);
      }
      _rejected.clear();
    }

    // Check if newly added position is off
    if (!isValidNewPosition(position)) {
      _rejected.add(position);
      return;
    }

    _buffer.add(position);
    _rejected.clear();
    if (_buffer.length > buffer_size) {
      return await _tripWrapper.add(_buffer.removeAt(0));
    }
  }

  @override
  Future<double> calculateEndProbability() {
    return _tripWrapper.calculateEndProbability();
  }

  @override
  Future<WrapperResult<Trip>> get({bool preliminary = false}) async {
    WrapperResult<Trip> result = await _tripWrapper.get(preliminary: preliminary);
    return result;
  }

  @override
  Map<String, dynamic> save() {
    Map<String, dynamic> json = Map<String, dynamic>();
    json["buffer"] = _buffer.map((e) => e.toJson()).toList();
    json["rejected"] = _rejected.map((e) => e.toJson()).toList();
    json["tripWrapper"] = _tripWrapper.save();
    return json;
  }

  @override
  void load(Map<String, dynamic> json) {
    List<dynamic> buffer = json["buffer"];
    List<dynamic> rejected = json["rejected"];
    _buffer.clear();
    _rejected.clear();
    _buffer.addAll(buffer.map((e) => Position.fromJson(e)));
    _rejected.addAll(rejected.map((e) => Position.fromJson(e)));
    _tripWrapper.load(json["tripWrapper"]);
  }
}
