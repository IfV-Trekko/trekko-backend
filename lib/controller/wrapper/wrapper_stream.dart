import 'package:trekko_backend/controller/wrapper/position_wrapper.dart';
import 'package:trekko_backend/model/position.dart';
import 'package:trekko_backend/model/trip/position_collection.dart';

abstract class WrapperStream<R extends PositionCollection> {

  Stream<R> getResults();

  void add(Position data);

  PositionWrapper<R> getWrapper();

  bool isProcessing();

}