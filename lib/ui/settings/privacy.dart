import 'package:event_bloc/event_bloc_widgets.dart';
import 'package:event_essay/event_essay.dart';
import 'package:event_navigation/event_navigation.dart';
import 'package:flutter/material.dart';

class PrivacyScreen extends StatelessWidget {
  const PrivacyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Privacy Policy"),
        leading: BackButton(
            onPressed: () => context.fireEvent(
                NavigationEvent.popDeepNavigation.event, null)),
      ),
      body: const EssayScreen(path: ["privacy"]),
    );
  }
}
