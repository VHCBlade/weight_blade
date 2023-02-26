import 'package:flutter/material.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Settings")),
      body: ListView(
        children: [
          ListTile(
              title: const Text("Show Licenses"),
              onTap: () => showLicensePage(context: context)),
        ],
      ),
    );
  }
}
