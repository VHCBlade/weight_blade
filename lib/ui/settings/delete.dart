import 'package:event_bloc/event_bloc_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:weight_blade/bloc/settings/extension.dart';
import 'package:weight_blade/event/settings.dart';

class DeleteConfirmationSettings extends StatelessWidget {
  const DeleteConfirmationSettings({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = context.watchSettings;
    return ListTile(
      title: const Text("Show Delete Confirmation"),
      trailing: CupertinoSwitch(
        value: settings.showDeleteConfirmation,
        onChanged: (val) => context.fireEvent(SettingsEvent.saveSettings.event,
            settings..showDeleteConfirmation = val),
      ),
    );
  }
}
