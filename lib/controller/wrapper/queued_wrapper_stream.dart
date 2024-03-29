import 'dart:async';
import 'dart:collection';

import 'package:trekko_backend/controller/wrapper/data_wrapper.dart';
import 'package:trekko_backend/controller/wrapper/wrapper_stream.dart';
import 'package:trekko_backend/model/position.dart';

class QueuedWrapperStream<R> implements WrapperStream<R> {

  static const double END_PROBABILITY_THRESHOLD = 0.95;

  final Queue<Position> _dataQueue = Queue<Position>();
  final StreamController<R> _controller = StreamController<R>.broadcast();
  final Function wrapperFactory;
  late DataWrapper<R> _currentWrapper;
  bool _isProcessing = false;

  QueuedWrapperStream(this.wrapperFactory) {
    _currentWrapper = wrapperFactory.call();
  }

  void _process(Position position) async {
    double endProb = await _currentWrapper.calculateEndProbability();
    _currentWrapper.add(position);
    if (endProb > END_PROBABILITY_THRESHOLD) {
      _currentWrapper = wrapperFactory.call();
      R result = await _currentWrapper.get();
      _controller.add(result);
    }
  }

  void _processNextData() async {
    if (_dataQueue.isEmpty) {
      _isProcessing = false;
      return;
    }

    _isProcessing = true;
    _process(_dataQueue.removeFirst());
    _processNextData();
  }

  @override
  add(Position data) {
    _dataQueue.add(data);
    if (!_isProcessing) {
      _processNextData();
    }
  }

  @override
  Stream<R> getStream() {
    return _controller.stream;
  }
}
