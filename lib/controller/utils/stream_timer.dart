import 'dart:async';

class StreamTimer<T> {
  final Stream<T> Function() streamFunction;
  Timer? timer;
  StreamSubscription<T>? subscription;
  StreamController<T> controller = StreamController<T>.broadcast();

  StreamTimer(this.streamFunction);

  void refresh() {
    if (this.subscription != null) {
      this.subscription!.cancel();
    }

    this.subscription = this.streamFunction.call().listen((event) {
      controller.add(event);
    });
  }

  Stream<T> schedule(Duration duration) {
    controller.onListen = () {
      this.refresh();
      timer = Timer.periodic(duration, (timer) {
        this.refresh();
      });
    };

    controller.onCancel = () {
      this.subscription!.cancel();
      timer!.cancel();
    };

    return controller.stream;
  }
}
