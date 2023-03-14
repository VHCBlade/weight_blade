import 'dart:async';

import 'package:event_ads/event_ads.dart';
import 'package:event_bloc/event_bloc_widgets.dart';
import 'package:event_navigation/event_navigation.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:vhcblade_theme/vhcblade_picker.dart';
import 'package:vhcblade_theme/vhcblade_widget.dart';
import 'package:weight_blade/bloc/settings/extension.dart';
import 'package:weight_blade/ui/settings/convert.dart';
import 'package:weight_blade/ui/settings/delete.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return FadeThroughWidgetSwitcher(builder: (_) {
      final bloc = context.watchBloc<MainNavigationBloc<String>>();
      if (bloc.deepNavigationMap["settings"] != null) {
        final settings = context.watchSettings;
        switch (bloc.deepNavigationMap["settings"]!.leaf.value) {
          case 'theme':
            return VHCBladeThemePicker(
              navigateBack: () => context.fireEvent(
                  NavigationEvent.popDeepNavigation.event, null),
              enableAdUnlock: settings.enableAdsAppWide,
              unlockConfirmation: (_, context) async {
                final completer = Completer<bool>();
                context.fireEvent<RewardedAdCallback>(
                    AdEvent.showRewardedAdWithCallback.event, (result) async {
                  switch (result) {
                    case RewardResult.dismissed:
                      await showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                                title: const Text(
                                    "You need to watch the full ad to get the reward!"),
                                actions: [
                                  ElevatedButton(
                                      onPressed: () =>
                                          Navigator.of(context).pop(),
                                      child: const Text("Understood"))
                                ],
                              ));
                      completer.complete(false);
                      break;

                    case RewardResult.noLoad:
                      await showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                                title: const Text(
                                    "We were unable to load an ad. Have this one on us!"),
                                actions: [
                                  ElevatedButton(
                                      onPressed: () =>
                                          Navigator.of(context).pop(),
                                      child: const Text("Thanks"))
                                ],
                              ));
                      completer.complete(false);
                      break;
                    case RewardResult.earned:
                    default:
                      completer.complete(true);
                  }
                });
                return await completer.future;
              },
            );
          default:
        }
      }

      return const SettingsPage();
    });
  }
}

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Settings")),
      body: ListView(
        children: [
          Column(children: [
            const SizedBox(height: 20),
            Image.asset("icons/180x180.png"),
            const SizedBox(height: 10),
            Text("Weight Blade",
                style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 10),
          ]),
          const ListTile(title: Text("Change Settings"), selected: true),
          const DeleteConfirmationSettings(),
          const AutomaticallyConverUnitsSetting(),
          ListTile(
              title: const Text("Change Theme"),
              onTap: () => context.fireEvent(
                  NavigationEvent.pushDeepNavigation.event, "theme")),
          const ListTile(title: Text("Others"), selected: true),
          ListTile(
              title: const Text("Show Licenses"),
              onTap: () => showLicensePage(context: context)),
          ListTile(
              title: const Text("Our Other Apps"),
              onTap: () => launchUrl(
                    Uri.parse("https://vhcblade.com/#/apps"),
                    mode: LaunchMode.externalApplication,
                  )),
        ],
      ),
    );
  }
}
