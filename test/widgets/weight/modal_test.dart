import 'package:event_bloc_tester/event_bloc_widget_tester.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:weight_blade/model/weight.dart';
import 'package:weight_blade/ui/weight/modal.dart';

import 'modal_classes.dart';

void main() {
  group("Weight Widget Modal", () {
    group("Basic", basicTest);
    group("Keep Note", basicKeepNoteTest);
    // TODO WB-24
    // group("Edit", () {});
    // group("Edit Keep Note", () {});
  });
}

Map<String, WeightEntry? Function()> get commonTestCases => {
      "Null": () => null,
      "Basic 1": () => WeightEntry()
        ..dateTime = DateTime(1990, 7)
        ..weight = 200,
      "Basic 2": () => WeightEntry()
        ..dateTime = DateTime(1999, 12)
        ..weight = 100
        ..unit = WeightUnit.kg,
      "With Note": () => WeightEntry()
        ..dateTime = DateTime(1990, 7)
        ..weight = 200
        ..note = "Great",
      "With Note 2": () => WeightEntry()
        ..dateTime = DateTime(1999, 12)
        ..weight = 100
        ..unit = WeightUnit.kg
        ..note = "Amazing",
    };

void basicKeepNoteTest() {
  final tester = SerializableListWidgetTester<WeightEntry?>(
    testGroupName: "Weight Widget Modal",
    mainTestName: "Keep Note",
    // Change this value to determine whether you generate the output file or check against it.
    // mode: ListTesterMode.generateOutput,
    mode: ListTesterMode.testOutput,
    testFunction: (value, tester, widgetTester) async {
      final key = GlobalKey();
      await widgetTester.pumpWidget(WeightModalTester(
        buttonKey: key,
        keepNote: true,
        initialValue: value,
        tester: tester,
      ));
      await widgetTester.pumpAndSettle();

      await widgetTester.tap(find.byKey(key));
      await widgetTester.pumpAndSettle();
      await widgetTester.tap(find.byKey(weightEntryCancelKey));
      await widgetTester.pumpAndSettle();
      await widgetTester.tap(find.byKey(key));
      await widgetTester.pumpAndSettle();
      await widgetTester.tap(find.byKey(weightEntrySaveKey));
      await widgetTester.pumpAndSettle();
    },
    testMap: commonTestCases,
  );

  tester.runTests();
}

void basicTest() {
  final tester = SerializableListWidgetTester<WeightEntry?>(
    testGroupName: "Weight Widget Modal",
    mainTestName: "Basic",
    // Change this value to determine whether you generate the output file or check against it.
    // mode: ListTesterMode.generateOutput,
    mode: ListTesterMode.testOutput,
    testFunction: (value, tester, widgetTester) async {
      final key = GlobalKey();
      await widgetTester.pumpWidget(WeightModalTester(
        buttonKey: key,
        keepNote: false,
        initialValue: value,
        tester: tester,
      ));
      await widgetTester.pumpAndSettle();

      await widgetTester.tap(find.byKey(key));
      await widgetTester.pumpAndSettle();
      await widgetTester.tap(find.byKey(weightEntryCancelKey));
      await widgetTester.pumpAndSettle();
      await widgetTester.tap(find.byKey(key));
      await widgetTester.pumpAndSettle();
      await widgetTester.tap(find.byKey(weightEntrySaveKey));
      await widgetTester.pumpAndSettle();
    },
    testMap: commonTestCases,
  );

  tester.runTests();
}
