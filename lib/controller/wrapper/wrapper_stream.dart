import 'package:trekko_backend/model/position.dart';

abstract class WrapperStream<R> {

  Stream<R> getStream();

  Future<void> add(Position data);

  bool isProcessing();

}