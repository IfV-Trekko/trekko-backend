import 'package:trekko_backend/model/position.dart';
import 'package:trekko_backend/model/trip/position_collection.dart';

abstract class PositionWrapper<R extends PositionCollection> {
  Future<double> calculateEndProbability();

  Future add(Position position);

  Future<R> get({bool preliminary = false});

  Map<String, dynamic> save();

  void load(Map<String, dynamic> json);
}
