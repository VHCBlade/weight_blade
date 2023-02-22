import 'package:event_navigation/event_navigation.dart';
import 'package:flutter/material.dart';
import 'package:weight_blade/ui/coming_soon.dart';
import 'package:weight_blade/ui/weight/screen.dart';

class MainTransferScreen extends StatelessWidget {
  const MainTransferScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MainNavigationFullScreenCarousel(
        navigationOptions: const ["weigh", "sets", "import", "settings"],
        navigationBuilder: (_, navigation) {
          switch (navigation) {
            case 'weigh':
              return const WeightScreen();
            case 'reminder':
            case 'settings':
            default:
              return const ComingSoonScreen();
          }
        });
  }
}
