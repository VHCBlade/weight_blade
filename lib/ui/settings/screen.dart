import 'package:event_ads/event_ads.dart';
import 'package:event_bloc/event_bloc_widgets.dart';
import 'package:event_essay/event_essay.dart';
import 'package:event_navigation/event_navigation.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:vhcblade_theme/vhcblade_picker.dart';
import 'package:vhcblade_theme/vhcblade_widget.dart';
import 'package:weight_blade/bloc/settings/extension.dart';
import 'package:weight_blade/ui/settings/ad.dart';
import 'package:weight_blade/ui/settings/convert.dart';
import 'package:weight_blade/ui/settings/delete.dart';
import 'package:weight_blade/ui/settings/privacy.dart';

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
              unlockConfirmation: (_, context) {
                context.fireEvent(AdEvent.showAd.event, null);
                return true;
              },
            );
          case 'privacy':
            return const PrivacyScreen();
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
          if (kIsWeb)
            ListTile(
              title: const Text("Get the Android Mobile App"),
              onTap: () => context.fireEvent(EssayEvent.url.event,
                  "https://play.google.com/store/apps/details?id=com.vhcblade.weight_blade&hl=en_US&gl=US"),
            ),
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
              onTap: () => context.fireEvent(
                  EssayEvent.url.event, "https://vhcblade.com/#/apps")),
          ListTile(
              title: const Text("Source Code"),
              onTap: () => context.fireEvent(EssayEvent.url.event,
                  "https://github.com/VHCBlade/weight_blade")),
          ListTile(
              title: const Text("Send Us Your Feedback"),
              onTap: () => context.fireEvent(
                  EssayEvent.url.event, "mailto:weight@vhcblade.com")),
          ListTile(
              title: const Text("Privacy Policy"),
              onTap: () => context.fireEvent(
                  NavigationEvent.pushDeepNavigation.event, "privacy")),
          if (!kIsWeb)
            ListTile(
              title: const Text("Ad Settings"),
              onTap: () => showDialog(
                context: context,
                builder: (_) => const AdSettingsWidget(),
              ),
            ),
        ],
      ),
    );
  }
}
