import 'package:geolocator/geolocator.dart';

enum PositionAccuracy {
  low(LocationAccuracy.low),
  medium(LocationAccuracy.medium),
  high(LocationAccuracy.high),
  best(LocationAccuracy.best);

  final LocationAccuracy accuracy;

  const PositionAccuracy(this.accuracy);
}
