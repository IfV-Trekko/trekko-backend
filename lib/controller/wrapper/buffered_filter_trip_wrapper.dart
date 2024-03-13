import 'package:app_backend/controller/utils/position_utils.dart';
import 'package:app_backend/controller/wrapper/analyzing_trip_wrapper.dart';
import 'package:app_backend/controller/wrapper/trip_wrapper.dart';
import 'package:app_backend/model/position.dart';
import 'package:app_backend/model/trip/trip.dart';

class BufferedFilterTripWrapper implements TripWrapper {
  static const buffer_size = 1;
  static const max_rejected = 3;
  static const tolerance = 0.1;

  final TripWrapper _tripWrapper;
  final List<Position> _buffer = List.empty(growable: true);
  final List<Position> _rejected = List.empty(growable: true);

  BufferedFilterTripWrapper.withBuilder(this._tripWrapper);

  BufferedFilterTripWrapper() : _tripWrapper = AnalyzingTripWrapper();

  bool isValidNewPosition(Position newPosition) {
    if (_buffer.isEmpty) {
      // Wenn der Buffer leer ist, ist jede neue Position valide
      return true;
    }

    // Hole die letzte Position aus dem Buffer
    Position lastPosition = _buffer.last;

    // Berechne die Distanz und Zeitdifferenz
    double distance = PositionUtils.distanceBetween(lastPosition, newPosition);
    int timeDiffInSeconds =
        newPosition.timestamp.difference(lastPosition.timestamp).inSeconds;

    // Vermeide Division durch Null
    if (timeDiffInSeconds <= 0) {
      return false; // oder handle diesen Fall anders
    }

    // Berechne die Geschwindigkeit basierend auf der Distanz und der Zeitdifferenz
    double calculatedSpeed = distance / timeDiffInSeconds;

    // Überprüfe, ob die berechnete Geschwindigkeit im erwarteten Bereich liegt
    // Hier könnte z.B. eine Toleranzgrenze von 10% der gemeldeten Geschwindigkeit angenommen werden
    double speedDifference = (calculatedSpeed - newPosition.speed).abs();

    // Angenommene Toleranz: 10% der gemeldeten Geschwindigkeit
    bool isSpeedDifferenceAcceptable =
        speedDifference <= newPosition.speed * tolerance;

    return isSpeedDifferenceAcceptable;
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
