import 'package:event_bloc/event_bloc_widgets.dart';
import 'package:event_navigation/event_navigation.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:vhcblade_theme/vhcblade_widget.dart';
import 'package:weight_blade/bloc/weight_entry.dart';
import 'package:weight_blade/bloc_builders.dart';
import 'package:weight_blade/event/ledger.dart';
import 'package:weight_blade/main_transfer.dart';
import 'package:weight_blade/repository_builders.dart';
import 'package:vhcblade_theme/vhcblade_theme.dart';

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
    return MultiRepositoryProvider(
      repositoryBuilders: pocRepositoryBuilders,
      child: MultiBlocProvider(
        blocBuilders: blocBuilders,
        child: Builder(
          builder: (context) {
            return EventNavigationApp(
              title: 'Weight Blade',
              theme: createTheme(),
              builder: (_) => Overlay(
                initialEntries: [
                  OverlayEntry(
                    builder: (context) => Navigator(
                      onGenerateRoute: (_) => MaterialPageRoute(
                        builder: (_) => const MainScreen(),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  late final _loading = GlobalKey(debugLabel: "Initial Loading");
  late final _main = GlobalKey(debugLabel: "Main Parent");
  @override
  void initState() {
    super.initState();
    context.fireEvent<void>(LedgerEvent.loadLedger.event, null);
  }

  Widget buildWidget(BuildContext context) {
    final bloc = BlocProvider.watch<WeightEntryBloc>(context);

    if (bloc.loading) {
      return Scaffold(
          key: _loading,
          body: const Center(child: CupertinoActivityIndicator()));
    }
    final navBloc = BlocProvider.watch<MainNavigationBloc<String>>(context);

    final navigationBar = MainNavigationBar(
      currentNavigation: navBloc.currentMainNavigation,
      navigationPossibilities: const ["weigh", "reminder", "settings"],
      builder: (index, onTap) => BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: index,
        onTap: onTap,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
              icon: Icon(Icons.push_pin), label: 'Reminder'),
          BottomNavigationBarItem(
              icon: Icon(Icons.settings), label: 'Settings'),
        ],
      ),
    );

    return Scaffold(
      key: _main,
      bottomNavigationBar: navigationBar,
      body: const MainTransferScreen(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FadeThroughWidgetSwitcher(
      duration: const Duration(milliseconds: 1000),
      builder: (context) => buildWidget(context),
    );
  }
}
