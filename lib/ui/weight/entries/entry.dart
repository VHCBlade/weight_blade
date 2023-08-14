import 'package:event_modals/event_modals.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:weight_blade/event/weight.dart';
import 'package:weight_blade/model/weight.dart';
import 'package:weight_blade/ui/weight/entries/delete.dart';
import 'package:weight_blade/ui/weight/entries/note.dart';
import 'package:weight_blade/ui/weight/modal.dart';

final dateFormatter = DateFormat("MMM dd, yyyy").addPattern("jm", "\n");

class WeightEntryWidget extends StatelessWidget {
  final WeightEntry entry;
  const WeightEntryWidget({super.key, required this.entry});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(5, 5, 5, 0),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              WeightEntryHeader(entry: entry),
              if (entry.note.isNotEmpty)
                GestureDetector(
                  onTap: () => editWeightEntryNote(context, entry),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: Text(
                      entry.note,
                      textAlign: TextAlign.left,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class WeightEntryHeader extends StatelessWidget {
  final WeightEntry entry;

  const WeightEntryHeader({super.key, required this.entry});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("${entry.weight} ${entry.unit.name}"),
            Text(dateFormatter.format(entry.dateTime),
                style: Theme.of(context).textTheme.labelSmall),
          ],
        ),
        Expanded(child: Container()),
        IconButton(
            onPressed: () => editWeightEntryNote(context, entry),
            icon: Icon(entry.note.isEmpty ? Icons.notes : Icons.edit_note)),
        IconButton(
            onPressed: () => deleteWeightEntry(context, entry),
            icon: const Icon(Icons.delete)),
        ElevatedButton(
          onPressed: () => showEventDialog<WeightEntry>(
            context: context,
            builder: (_) => WeightEntryWithDateModal(
              entry: entry,
              editWeight: true,
            ),
            onResponse: (eventChannel, value) =>
                eventChannel.fireEvent<WeightEntry>(
                    WeightEvent.updateWeightEntry.event, value),
          ),
          child: const Text("Edit"),
        ),
      ],
    );
  }
}
