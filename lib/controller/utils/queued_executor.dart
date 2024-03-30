import 'dart:collection';

class QueuedExecutor {

  final Queue<Function> _dataQueue = Queue<Function>();
  bool _isProcessing = false;

  void _processNextData() async {
    if (_dataQueue.isEmpty) {
      _isProcessing = false;
      return;
    }

    _isProcessing = true;
    await _dataQueue.removeFirst().call();
    _processNextData();
  }

  add(Function data) {
    _dataQueue.add(data);
    if (!_isProcessing) {
      _processNextData();
    }
  }

  bool get isProcessing => _isProcessing || _dataQueue.isNotEmpty;
}