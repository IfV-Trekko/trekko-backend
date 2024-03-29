import 'package:trekko_backend/controller/analysis/reduction.dart';
enum DoubleReduction with Reduction<double> implements Reduction<double> {
  SUM,
  MAX,
  MIN;

  double reduce(double a, double b) {
    switch (this) {
      case DoubleReduction.SUM:
        return a + b;
      case DoubleReduction.MAX:
        return a > b ? a : b;
      case DoubleReduction.MIN:
        return a < b ? a : b;
    }
  }
}
