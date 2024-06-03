import 'dart:async';

import 'package:trekko_backend/controller/utils/queued_executor.dart';
import 'package:trekko_backend/controller/wrapper/data_wrapper.dart';
import 'package:trekko_backend/controller/wrapper/wrapper_result.dart';
import 'package:trekko_backend/controller/wrapper/wrapper_stream.dart';
import 'package:trekko_backend/model/tracking/raw_phone_data.dart';

class QueuedWrapperStream<R> implements WrapperStream<R> {
  static const double CONFIDENCE_THRESHOLD = 0.95;

  final QueuedExecutor _dataProcessor = QueuedExecutor();
  final StreamController<R> _controller;
  final Function(Iterable<RawPhoneData>) wrapperFactory;
  late DataWrapper<R> _currentWrapper;

  QueuedWrapperStream(DataWrapper<R> initialWrapper, this.wrapperFactory,
      {sync = false})
      : _controller = StreamController.broadcast(sync: sync),
        this._currentWrapper = initialWrapper;

  Future<void> _process(Iterable<RawPhoneData> position) async {
    await _currentWrapper.add(position);
    WrapperResult<R> result = await _currentWrapper.get();
    if (result.confidence > CONFIDENCE_THRESHOLD && result.result != null) {
      _currentWrapper = wrapperFactory.call(result.unusedDataPoints);
      _controller.add(result.result!);
    }
  }

  @override
  add(Iterable<RawPhoneData> data) {
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
  DataWrapper<R> getWrapper() {
    return _currentWrapper;
  }
}
