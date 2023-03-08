import 'package:event_bloc/event_bloc_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:weight_blade/bloc/settings/extension.dart';
import 'package:weight_blade/event/settings.dart';

class AutomaticallyConverUnitsSetting extends StatelessWidget {
  const AutomaticallyConverUnitsSetting({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = context.watchSettings;
    return ListTile(
      title: const Text("Automatically Convert Weight on Unit Conversion"),
      trailing: CupertinoSwitch(
        value: settings.automaticallyConvertUnits,
        onChanged: (val) => context.fireEvent(SettingsEvent.saveSettings.event,
            settings..automaticallyConvertUnits = val),
      ),
    );
  }
}
