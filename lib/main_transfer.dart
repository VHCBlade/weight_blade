import 'package:event_navigation/event_navigation.dart';
import 'package:flutter/material.dart';
import 'package:weight_blade/ui/coming_soon.dart';

class MainTransferScreen extends StatelessWidget {
  const MainTransferScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MainNavigationFullScreenCarousel(
        navigationOptions: const ["review", "sets", "import", "settings"],
        navigationBuilder: (_, navigation) {
          switch (navigation) {
            case 'settings':
            default:
              return const ComingSoonScreen();
          }
        });
  }
}
