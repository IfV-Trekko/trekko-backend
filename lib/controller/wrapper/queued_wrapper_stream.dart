import 'dart:async';

import 'package:trekko_backend/controller/utils/queued_executor.dart';
import 'package:trekko_backend/controller/wrapper/position_wrapper.dart';
import 'package:trekko_backend/controller/wrapper/wrapper_result.dart';
import 'package:trekko_backend/controller/wrapper/wrapper_stream.dart';
import 'package:trekko_backend/model/tracking/raw_phone_data.dart';
import 'package:trekko_backend/model/trip/position_collection.dart';

class QueuedWrapperStream<R extends PositionCollection>
    implements WrapperStream<R> {
  static const double END_PROBABILITY_THRESHOLD = 0.95;

  final QueuedExecutor _dataProcessor = QueuedExecutor();
  final StreamController<R> _controller;
  final Function wrapperFactory;
  late PositionWrapper<R> _currentWrapper;

  QueuedWrapperStream(PositionWrapper<R> initialWrapper, this.wrapperFactory,
      {sync = false})
      : _controller = StreamController.broadcast(sync: sync),
        this._currentWrapper = initialWrapper;

  Future<void> _process(RawPhoneData position) async {
    await _currentWrapper.add(position);
    double endProb = await _currentWrapper.calculateEndProbability();
    if (endProb > END_PROBABILITY_THRESHOLD) {
      WrapperResult<R> result = await _currentWrapper.get();
      _currentWrapper = wrapperFactory.call();
      _controller.add(result.getResult());
      //todo do something with unused data points.
    }
  }

  @override
  add(RawPhoneData data) {
    _dataProcessor.add(() async => await _process(data));
  }

  @override
  Stream<R> getResults() {
    return _controller.stream;
  }

  @override
  bool isProcessing() {
    return _dataProcessor.isProcessing;
  }

  @override
  PositionWrapper<R> getWrapper() {
    return _currentWrapper;
  }
}
