import 'package:event_ads/event_ads.dart';
import 'package:event_alert/event_alert_widgets.dart';
import 'package:flutter/material.dart';

class WatcherLayer extends StatelessWidget {
  const WatcherLayer({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return LoadingAdWatcher(
      child: AlertWatcher(
        child: child,
      ),
    );
  }
}
