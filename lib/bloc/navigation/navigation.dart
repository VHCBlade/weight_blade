import 'package:event_navigation/event_navigation.dart';
import 'package:event_bloc/event_bloc.dart';

const POSSIBLE_NAVIGATIONS = <String>{
  "weigh",
  "reminder",
  "import",
  "settings",
  "error",
};

MainNavigationBloc<String> generateNavigationBloc(
    {BlocEventChannel? parentChannel}) {
  final bloc = MainNavigationBloc<String>(
    parentChannel: parentChannel,
    strategy: ListNavigationStrategy(
      possibleNavigations: POSSIBLE_NAVIGATIONS.toList(),
      defaultNavigation: 'weigh',
      navigationOnError: 'error',
    ),
    undoStrategy: UndoRedoMainNavigationStrategy(),
  );

  return bloc;
}
