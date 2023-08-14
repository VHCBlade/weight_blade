import 'package:event_bloc_tester/event_bloc_widget_tester.dart';
import 'package:event_modals/event_modals.dart';
import 'package:flutter/material.dart';
import 'package:weight_blade/model/weight.dart';
import 'package:weight_blade/ui/weight/modal.dart';

import '../default.dart';

class WeightModalTester extends StatelessWidget {
  final Key? buttonKey;
  final WeightEntry? initialValue;
  final bool keepNote;
  final SerializableTester tester;
  const WeightModalTester(
      {super.key,
      this.buttonKey,
      this.initialValue,
      required this.keepNote,
      required this.tester});

  @override
  Widget build(BuildContext context) {
    return DefaultTestApp(
      child: Builder(
        builder: (context) => ElevatedButton(
          key: buttonKey,
          onPressed: () => showEventDialog<WeightEntry>(
              context: context,
              builder: (_) => WeightEntryWithDateModal(
                  entry: initialValue, editWeight: keepNote),
              onResponse: (eventChannel, entry) {
                tester.addTestValue(entry.dateTime
                    .isAfter(initialValue?.dateTime ?? DateTime(1990)));
                tester.addTestValue("${entry.unit}");
                tester.addTestValue(entry.note);
                tester.addTestValue(entry.weight);
              },
              onNullResponse: (eventChannel) =>
                  tester.addTestValue("Cancelled!")),
          child: const Text("Test"),
        ),
      ),
    );
  }
}
