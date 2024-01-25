import 'package:app_backend/controller/analysis/calculation_reductor.dart';
import 'package:fling_units/fling_units.dart';

enum DistanceReduction implements Reduction<Distance> {
  AVERAGE,
  SUM,
  MAX,
  MIN;

  Distance reduce(Distance a, Distance b) {
    switch (this) {
      case DistanceReduction.AVERAGE:
        return (a + b) / 2;
      case DistanceReduction.SUM:
        return a + b;
      case DistanceReduction.MAX:
        return a > b ? a : b;
      case DistanceReduction.MIN:
        return a < b ? a : b;
    }
  }
}

enum DurationReduction implements Reduction<Duration> {
  AVERAGE,
  SUM,
  MAX,
  MIN;

  Duration reduce(Duration a, Duration b) {
    switch (this) {
      case DurationReduction.AVERAGE:
        return (a + b) ~/ 2;
      case DurationReduction.SUM:
        return a + b;
      case DurationReduction.MAX:
        return a > b ? a : b;
      case DurationReduction.MIN:
        return a < b ? a : b;
    }
  }
}

enum SpeedReduction
    implements
        Reduction<
            DerivedMeasurement<Measurement<Distance>, Measurement<Time>>> {
  AVERAGE,
  MAX,
  MIN;

  DerivedMeasurement<Measurement<Distance>, Measurement<Time>> reduce(
      DerivedMeasurement<Measurement<Distance>, Measurement<Time>> a,
      DerivedMeasurement<Measurement<Distance>, Measurement<Time>> b) {
    switch (this) {
      case SpeedReduction.AVERAGE:
        return (a + b) / 2;
      case SpeedReduction.MAX:
        return a > b ? a : b;
      case SpeedReduction.MIN:
        return a < b ? a : b;
    }
  }
}
