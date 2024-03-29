import 'package:trekko_backend/model/position.dart';

abstract class WrapperStream<R> {

  Stream<R> getStream();

  add(Position data);

}