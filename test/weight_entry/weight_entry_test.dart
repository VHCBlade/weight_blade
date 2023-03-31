import 'package:flutter_test/flutter_test.dart';
import 'package:weight_blade/model/weight.dart';

WeightEntry get genWeightEntry => WeightEntry()
  ..dateTime = DateTime(1980, 2, 2)
  ..note = "Stamp"
  ..unit = WeightUnit.kg
  ..weight = 100;
WeightEntry get genWeightEntry2 => WeightEntry()
  ..dateTime = DateTime(1990, 4, 1)
  ..note = null
  ..unit = WeightUnit.lbs
  ..weight = 200;

void main() {
  group("Weight Entry Model", () {
    test("Save and Load", saveAndLoadTest);
    test("Conversion", conversionTest);
  });
}

void conversionTest() {
  final one = genWeightEntry;

  expect(one.weightInPounds, 220.46230000000003);
  expect(one.weightInUnits(WeightUnit.kg), 100);

  final two = genWeightEntry2;

  expect(two.weightInPounds, 200);
  expect(two.weightInUnits(WeightUnit.kg), 90.71845843937942);
}

void saveAndLoadTest() {
  final one = genWeightEntry;
  final two = genWeightEntry2;

  two.copy(one);

  compareSame(one, two);
  compareSame(two, genWeightEntry);

  one.copy(genWeightEntry2);
  two.copy(genWeightEntry2);

  compareSame(one, two);
  compareSame(one, genWeightEntry2);
}

void compareSame(WeightEntry one, WeightEntry two) {
  expect(one.dateTime, two.dateTime);
  expect(one.note, two.note);
  expect(one.unit, two.unit);
  expect(one.weight, two.weight);
}
