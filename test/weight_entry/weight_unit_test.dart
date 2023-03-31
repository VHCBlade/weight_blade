import 'package:flutter_test/flutter_test.dart';
import 'package:weight_blade/model/weight.dart';

void main() {
  group("WeightUnit", () {
    test("kg", () {
      expect(WeightUnit.kg.convertFromLbs(100), 45.35922921968971);
      expect(WeightUnit.kg.convertToLbs(45.35922921968971), 100);
      expect(WeightUnit.kg.convertToLbs(150), 330.69345000000004);
      expect(WeightUnit.kg.convertFromLbs(330.69345000000004), 150);
    });
  });
}
