import 'dart:async';

import 'package:trekko_backend/controller/utils/queued_executor.dart';
import 'package:trekko_backend/controller/wrapper/data_wrapper.dart';
import 'package:trekko_backend/controller/wrapper/wrapper_stream.dart';
import 'package:trekko_backend/model/position.dart';

class QueuedWrapperStream<R> implements WrapperStream<R> {
  static const double END_PROBABILITY_THRESHOLD = 0.95;

  final QueuedExecutor _dataProcessor = QueuedExecutor();
  final StreamController<R> _controller;
  final Function wrapperFactory;
  late DataWrapper<R> _currentWrapper;

  QueuedWrapperStream(this.wrapperFactory, {sync = false})
      : _controller = StreamController<R>.broadcast(sync: sync) {
    _currentWrapper = wrapperFactory.call();
  }

  Future<void> _process(Position position) async {
    _currentWrapper.add(position);
    double endProb = await _currentWrapper.calculateEndProbability();
    if (endProb > END_PROBABILITY_THRESHOLD) {
      R result = await _currentWrapper.get();
      _currentWrapper = wrapperFactory.call();
      _controller.add(result);
    }
  }

  @override
  add(Position data) async {
    await _dataProcessor.add(() async => await _process(data));
  }

  @override
  Stream<R> getStream() {
    return _controller.stream;
  }

  @override
  bool isProcessing() {
    return _dataProcessor.isProcessing;
  }
}
