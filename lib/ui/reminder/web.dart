import 'package:event_bloc/event_bloc_widgets.dart';
import 'package:event_essay/event_essay.dart';
import 'package:flutter/material.dart';

class WebRemindersScreen extends StatelessWidget {
  const WebRemindersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Reminders")),
      body: Center(
          child: ListView(
        shrinkWrap: true,
        children: [
          Text("Web does not support Reminders. Try the mobile app!",
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineLarge),
          ElevatedButton(
              onPressed: () => context.fireEvent(EssayEvent.url.event,
                  "https://play.google.com/store/apps/details?id=com.vhcblade.weight_blade&hl=en_US&gl=US"),
              child: Text(
                "Android App Link",
                style: Theme.of(context).textTheme.headlineSmall,
              ))
        ],
      )),
    );
  }
}
