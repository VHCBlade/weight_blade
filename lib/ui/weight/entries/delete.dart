import 'package:event_bloc/event_bloc_widgets.dart';
import 'package:flutter/material.dart';
import 'package:weight_blade/bloc/settings/extension.dart';
import 'package:weight_blade/event/weight.dart';
import 'package:weight_blade/model/weight.dart';

void deleteWeightEntry(BuildContext context, WeightEntry entry) async {
  final settings = context.readSettings;
  final eventChannel = context.eventChannel;

  final shouldDelete = !settings.showDeleteConfirmation
      ? true
      : (await showDialog<bool>(
              context: context,
              builder: (_) => AlertDialog(
                    title: const Text(
                        "Are you sure you want to delete this weight entry?"),
                    actions: [
                      OutlinedButton(
                          onPressed: () => Navigator.of(context).pop(false),
                          child: const Text("Cancel")),
                      ElevatedButton(
                          onPressed: () => Navigator.of(context).pop(true),
                          child: const Text("Confirm"))
                    ],
                  )) ??
          false);

  if (shouldDelete) {
    eventChannel.fireEvent(WeightEvent.deleteWeightEntry.event, entry);
  }
}
