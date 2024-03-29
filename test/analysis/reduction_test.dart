import 'package:app_backend/controller/analysis/reductions.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {

  test("Test SUM reduction", () {
    expect(DoubleReduction.SUM.reduce(1, 2), equals(3));
  });

  test("Test MAX reduction", () {
    expect(DoubleReduction.MAX.reduce(1, 2), equals(2));
  });

  test("Test MIN reduction", () {
    expect(DoubleReduction.MIN.reduce(1, 2), equals(1));
  });
}