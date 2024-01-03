import 'package:geolocator/geolocator.dart';

abstract class DataWrapper<R> {

  Future<double> calculateEndProbability();

  Future<void> add(Position position);

  int collectedDataPoints();

  Future<R> get();

}