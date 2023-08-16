import 'package:event_bloc/event_bloc_widgets.dart';
import 'package:event_navigation/event_navigation.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:vhcblade_theme/vhcblade_picker.dart';
import 'package:vhcblade_theme/vhcblade_widget.dart';
import 'package:weight_blade/bloc/import_export.dart';
import 'package:weight_blade/bloc/weight_entry.dart';
import 'package:weight_blade/bloc_builders.dart';
import 'package:weight_blade/event/ledger.dart';
import 'package:weight_blade/event/reminder.dart';
import 'package:weight_blade/event/settings.dart';
import 'package:weight_blade/main_transfer.dart';
import 'package:weight_blade/repository_builders.dart';
import 'package:weight_blade/ui/import-export/screen.dart';
import 'package:weight_blade/ui/watcher/watcher_layer.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocEventChannelDebuggerProvider(
      create: (context, channel) => BlocEventChannelDebugger(
        parentChannel: channel,
        printHandled: false,
        printUnhandled: true,
      ),
      child: MultiRepositoryProvider(
        repositoryBuilders: pocRepositoryBuilders,
        child: MultiBlocProvider(
          blocBuilders: blocBuilders,
          child: VHCBladeThemeBuilder(
            builder: (context, theme) => EventNavigationApp(
              title: 'Weight Blade',
              theme: theme,
              builder: (_) => Overlay(
                initialEntries: [
                  OverlayEntry(
                    builder: (context) => Navigator(
                      onGenerateRoute: (_) => MaterialPageRoute(
                        builder: (_) => const WatcherLayer(child: MainScreen()),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final bloc = context.watchBloc<ImportExportBloc>();
    return FadeThroughWidgetSwitcher(
      duration: const Duration(milliseconds: 1000),
      builder: (_) => bloc.showImportExportScreen
          ? const ImportExportScreen()
          : const MainParentScreen(),
    );
  }
}

class MainParentScreen extends StatefulWidget {
  const MainParentScreen({Key? key}) : super(key: key);

  @override
  State<MainParentScreen> createState() => _MainParentScreenState();
}

class _LoadingScreen extends StatelessWidget {
  const _LoadingScreen();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: CupertinoActivityIndicator()),
    );
  }
}

class _MainParentScreenState extends State<MainParentScreen>
    with WidgetsBindingObserver {
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        context.fireEvent<void>(ReminderEvent.loadReminder.event, null);
        break;
      case AppLifecycleState.detached:
      case AppLifecycleState.inactive:
      case AppLifecycleState.paused:
        break;
    }
  }

  @override
  void initState() {
    super.initState();
    context
      ..fireEvent<void>(
        LedgerEvent.loadLedger.event,
        null,
        withDelay: true,
      )
      ..fireEvent<void>(
        ReminderEvent.loadReminder.event,
        null,
        withDelay: true,
      )
      ..fireEvent<void>(
        SettingsEvent.loadSettings.event,
        null,
        withDelay: true,
      );
  }

  Widget buildWidget(BuildContext context) {
    final bloc = context.watchBloc<WeightEntryBloc>();

    if (bloc.loading) {
      return const _LoadingScreen();
    }
    final navBloc = context.watchBloc<MainNavigationBloc<String>>();

    final navigationBar = MainNavigationBar(
      currentNavigation: navBloc.currentMainNavigation,
      navigationPossibilities: const ["weigh", "graph", "reminder", "settings"],
      builder: (index, onTap) => BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: index,
        onTap: onTap,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: 'Graph'),
          BottomNavigationBarItem(
              icon: Icon(Icons.push_pin), label: 'Reminder'),
          BottomNavigationBarItem(
              icon: Icon(Icons.settings), label: 'Settings'),
        ],
      ),
    );

    return Scaffold(
      bottomNavigationBar: navigationBar,
      body: const MainTransferScreen(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FadeThroughWidgetSwitcher(
      duration: const Duration(milliseconds: 1000),
      builder: buildWidget,
    );
  }
}
