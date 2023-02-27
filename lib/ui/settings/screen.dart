import 'package:flutter/material.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

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
          ]),
          ListTile(
              title: const Text("Show Licenses"),
              onTap: () => showLicensePage(context: context)),
        ],
      ),
    );
  }
}
