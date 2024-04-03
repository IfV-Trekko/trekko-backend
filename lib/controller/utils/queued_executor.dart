import 'dart:collection';

class QueuedExecutor {

  final Queue<Future Function()> _dataQueue = Queue<Future Function()>();
  bool _isProcessing = false;

  Future<void> _processNextData() async {
    if (_dataQueue.isEmpty) {
      _isProcessing = false;
      return;
    }

    _isProcessing = true;
    var function = _dataQueue.removeFirst();
    await function.call();
    _processNextData();
  }

  void add(Future Function() data) {
    _dataQueue.add(data);
    if (!_isProcessing) {
      _processNextData();
    }
  }

  bool get isProcessing => _isProcessing || _dataQueue.isNotEmpty;
}