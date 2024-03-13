import 'package:app_backend/controller/analysis/calculation.dart';

mixin Reduction<T> implements Calculation<T> {

  @override
  T? calculate(Iterable<T> objects) {
    return objects.reduce(reduce);
  }

  T reduce(T a, T b);
}