import 'package:trekko_backend/controller/wrapper/position_wrapper.dart';
import 'package:trekko_backend/model/trip/position_collection.dart';

import '../../model/position.dart';

class WrapperResult<R extends PositionCollection> {
  final R result;
  final List<Position> unusedDataPoints;

  WrapperResult(this.result, this.unusedDataPoints);

  R getResult() {
    return result;
  }

  List<Position> getUnusedDataPoints() {
    return unusedDataPoints;
  }
}