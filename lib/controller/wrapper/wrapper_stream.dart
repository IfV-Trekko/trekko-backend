import 'package:trekko_backend/model/position.dart';

abstract class WrapperStream<R> {

  Stream<R> getResults();

  Future<void> add(Position data);

  bool isProcessing();

}