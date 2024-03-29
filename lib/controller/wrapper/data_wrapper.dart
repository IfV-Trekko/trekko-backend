import 'package:trekko_backend/model/position.dart';

abstract class DataWrapper<R> {
  Future<double> calculateEndProbability();

  Future<void> add(Position position);

  Future<R> get();
}
