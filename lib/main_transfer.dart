import 'package:event_navigation/event_navigation.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:weight_blade/ui/coming_soon.dart';
import 'package:weight_blade/ui/reminder/web.dart';
import 'package:weight_blade/ui/settings/screen.dart';
import 'package:weight_blade/ui/weight/screen.dart';

class MainTransferScreen extends StatelessWidget {
  const MainTransferScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MainNavigationFullScreenCarousel(
        navigationOptions: const ["weigh", "reminder", "settings"],
        navigationBuilder: (_, navigation) {
          switch (navigation) {
            case 'weigh':
              return const WeightScreen();
            case 'settings':
              return const SettingsScreen();
            case 'reminder':
              return kIsWeb
                  ? const WebRemindersScreen()
                  : const ComingSoonScreen();
            default:
              return const ComingSoonScreen();
          }
        });
  }
}
