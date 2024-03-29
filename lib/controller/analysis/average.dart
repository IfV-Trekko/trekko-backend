import 'calculation.dart';

class AverageCalculation implements Calculation<double> {
  @override
  double? calculate(Iterable<double> objects) {
    return objects.reduce((value, element) => (value + element)) /
        objects.length;
  }
}
