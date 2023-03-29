import 'package:event_bloc/event_bloc.dart';
import 'package:event_modals/event_modals.dart';
import 'package:flutter/material.dart';
import 'package:weight_blade/bloc/settings/extension.dart';
import 'package:weight_blade/event/weight.dart';
import 'package:weight_blade/model/weight.dart';

void deleteWeightEntry(BuildContext context, WeightEntry entry) {
  final settings = context.readSettings;

  showEventDialog<bool>(
    context: context,
    builder: (_) => AlertDialog(
      title: const Text("Are you sure you want to delete this weight entry?"),
      actions: [
        OutlinedButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text("Cancel")),
        ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text("Confirm"))
      ],
    ),
    showModal: settings.showDeleteConfirmation,
    defaultValue: !settings.showDeleteConfirmation,
    onResponse: (BlocEventChannel eventChannel, response) => response
        ? eventChannel.fireEvent(WeightEvent.deleteWeightEntry.event, entry)
        : null,
  );
}
