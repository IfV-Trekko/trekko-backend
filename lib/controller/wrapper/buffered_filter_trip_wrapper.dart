import 'package:app_backend/controller/utils/position_utils.dart';
import 'package:app_backend/controller/wrapper/analyzing_trip_wrapper.dart';
import 'package:app_backend/controller/wrapper/trip_wrapper.dart';
import 'package:app_backend/model/position.dart';
import 'package:app_backend/model/trip/trip.dart';

class BufferedFilterTripWrapper implements TripWrapper {
  static const buffer_size = 2;
  static const max_rejected = 3;
  static const tolerance = 50;

  final TripWrapper _tripWrapper;
  final List<Position> _buffer = List.empty(growable: true);
  final List<Position> _rejected = List.empty(growable: true);

  BufferedFilterTripWrapper.withBuilder(this._tripWrapper);

  BufferedFilterTripWrapper() : _tripWrapper = AnalyzingTripWrapper();

  double averageDistance() {
    double sum = 0;
    for (int i = 0; i < _buffer.length - 1; i++) {
      sum += PositionUtils.distanceBetween(_buffer[i], _buffer[i + 1]);
    }
    return sum / _buffer.length;
  }

  bool isValidNewPosition(Position newPosition) {
    if (_buffer.length < buffer_size) {
      return true;
    }

    Position lastPosition = _buffer.last;

    double distance = PositionUtils.distanceBetween(lastPosition, newPosition);
    double averageDistance = this.averageDistance();

    // If distance is more than tolerance meters off, we assume the GPS failed
    return distance <= averageDistance + tolerance;
  }

  @override
  Future<void> add(Position position) {
    return Future.microtask(() async {
      // Buffer positions and add them to the trip wrapper when the buffer is full
      // Throw away positions if they are off pattern, so the gps probably failed

      if (_rejected.length > max_rejected) {
        // Apparently the first position is off pattern, so we throw away the whole buffer and add the rejected positions
        _buffer.forEach((element) => _tripWrapper.add(element));
        _buffer.clear();
        _rejected.forEach((element) => _tripWrapper.add(element));
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
        return _tripWrapper.add(_buffer.removeAt(0));
      }
    });
  }

  @override
  Future<double> calculateEndProbability() {
    return _tripWrapper.calculateEndProbability();
  }

  @override
  Future<Trip> get() {
    return _tripWrapper.get();
  }
}
