import 'package:event_bloc/event_bloc_widgets.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:weight_blade/bloc/settings/settings.dart';
import 'package:weight_blade/event/settings.dart';
import 'package:weight_blade/model/settings.dart';

class AdSettingsWidget extends StatelessWidget {
  const AdSettingsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = context.watchBloc<SettingsBloc>().settings;
    return AlertDialog(
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            title: const Text("Disable Ads"),
            trailing: CupertinoSwitch(
                value: !settings.enableAdsAppWide,
                onChanged: (val) => context.fireEvent<WBSettings>(
                    SettingsEvent.saveSettings.event,
                    settings..enableAdsAppWide = !val)),
          ),
          ListTile(
            title: const Text("Weight Entries before ad is shown"),
            trailing: ElevatedButton(
              onPressed: () => context.fireEvent<WBSettings>(
                  SettingsEvent.saveSettings.event,
                  settings
                    ..showAdEveryNEntries =
                        (settings.showAdEveryNEntries + 5) % 25
                    ..showAdEveryNEntries = settings.showAdEveryNEntries == 0
                        ? 5
                        : settings.showAdEveryNEntries),
              child: Text("${settings.showAdEveryNEntries}"),
            ),
          ),
        ],
      ),
      actions: [
        ElevatedButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text("Close"),
        )
      ],
    );
  }
}
