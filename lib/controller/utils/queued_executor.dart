import 'dart:collection';

class QueuedExecutor {

  final Queue<Function> _dataQueue = Queue<Function>();
  bool _isProcessing = false;

  Future<void> _processNextData() async {
    if (_dataQueue.isEmpty) {
      _isProcessing = false;
      return;
    }

    _isProcessing = true;
    await _dataQueue.removeFirst().call();
    await _processNextData();
  }

  Future<void> add(Function data) async {
    _dataQueue.add(data);
    if (!_isProcessing) {
      await _processNextData();
    }
  }

  bool get isProcessing => _isProcessing || _dataQueue.isNotEmpty;
}