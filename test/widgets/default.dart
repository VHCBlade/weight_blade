import 'package:event_bloc/event_bloc_widgets.dart';
import 'package:event_navigation/event_navigation.dart';
import 'package:flutter/material.dart';
import 'package:weight_blade/bloc_builders.dart';
import 'package:weight_blade/repository_builders.dart';

class DefaultTestApp extends StatelessWidget {
  final Widget child;
  const DefaultTestApp({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      repositoryBuilders: fakeRepositoryBuilders,
      child: MultiBlocProvider(
        blocBuilders: blocBuilders,
        child: EventNavigationApp(
          builder: (context) => Overlay(
            initialEntries: [
              OverlayEntry(
                builder: (context) => Navigator(
                  onGenerateRoute: (_) =>
                      MaterialPageRoute(builder: (_) => child),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
