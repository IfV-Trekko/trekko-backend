import 'package:fling_units/fling_units.dart';

abstract class Reduction<T> {
  T reduce(T a, T b);
}

enum DefaultReduction implements Reduction<dynamic> {
  AVERAGE,
  SUM,
  MAX,
  MIN;

  Distance reduce(dynamic a, dynamic b) {
    switch (this) {
      case DefaultReduction.AVERAGE:
        return (a + b) / 2;
      case DefaultReduction.SUM:
        return a + b;
      case DefaultReduction.MAX:
        return a > b ? a : b;
      case DefaultReduction.MIN:
        return a < b ? a : b;
    }
  }
}
