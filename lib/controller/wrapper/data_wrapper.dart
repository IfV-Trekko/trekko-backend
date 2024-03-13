import 'package:app_backend/model/position.dart';

abstract class DataWrapper<R> {
  Future<double> calculateEndProbability();

  Future<void> add(Position position);

  int collectedDataPoints();

  Future<R> get();
}
