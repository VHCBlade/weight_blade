import 'package:flutter/material.dart';

class WebRemindersScreen extends StatelessWidget {
  const WebRemindersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Reminders")),
      body: Center(
        child: Text(
            "Web does not support Reminders. Try the mobile app (Coming Soon)",
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineLarge),
      ),
    );
  }
}
