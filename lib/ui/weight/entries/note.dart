import 'package:flutter/material.dart';

import 'package:event_bloc/event_bloc_widgets.dart';
import 'package:weight_blade/event/weight.dart';
import 'package:weight_blade/model/weight.dart';

void editWeightEntryNote(BuildContext context, WeightEntry entry) async {
  final eventChannel = context.eventChannel;

  final newNote = await showDialog<String>(
      context: context, builder: (_) => NoteDialog(initialNote: entry.note));

  if (newNote == null) {
    return;
  }

  eventChannel.fireEvent(
      WeightEvent.updateWeightEntry.event, entry..note = newNote);
}

class NoteDialog extends StatefulWidget {
  final String? initialNote;
  const NoteDialog({super.key, this.initialNote});

  @override
  State<NoteDialog> createState() => _NoteDialogState();
}

class _NoteDialogState extends State<NoteDialog> {
  late final controller = TextEditingController();
  late final focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    controller.text = widget.initialNote ?? "";
    focusNode.requestFocus();
  }

  @override
  void dispose() {
    controller.dispose();
    focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Edit Note"),
      content: TextField(
        focusNode: focusNode,
        controller: controller,
        onSubmitted: (val) => Navigator.of(context).pop(val),
        maxLines: 4,
      ),
      actions: [
        OutlinedButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text("Cancel")),
        ElevatedButton(
            onPressed: () => Navigator.of(context).pop(controller.text),
            child: const Text("Save")),
      ],
    );
  }
}
