enum CalculationReduction {
  AVERAGE,
  SUM,
  MAX,
  MIN;

  double apply(double a, double b) {
    switch (this) {
      case CalculationReduction.AVERAGE:
        return (a + b) / 2;
      case CalculationReduction.SUM:
        return a + b;
      case CalculationReduction.MAX:
        return a > b ? a : b;
      case CalculationReduction.MIN:
        return a < b ? a : b;
    }
  }
}
