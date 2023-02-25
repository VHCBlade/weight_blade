import 'package:event_bloc/event_bloc_widgets.dart';
import 'package:event_db/event_db.dart';
import 'package:event_navigation/event_navigation.dart';
import 'package:weight_blade/bloc/goal.dart';
import 'package:weight_blade/bloc/navigation/navigation.dart';
import 'package:weight_blade/bloc/weight_entry.dart';

final blocBuilders = [
  BlocBuilder<MainNavigationBloc<String>>(
      (read, channel) => generateNavigationBloc(parentChannel: channel)),
  BlocBuilder<WeightEntryBloc>((read, channel) => WeightEntryBloc(
      parentChannel: channel, repo: read.read<DatabaseRepository>())),
  BlocBuilder<WeightGoalBloc>((read, channel) => WeightGoalBloc(
      parentChannel: channel, repo: read.read<DatabaseRepository>())),
  BlocBuilder<WeightGoalWatcherBloc>(
    (read, channel) => WeightGoalWatcherBloc(
      parentChannel: channel,
      weightEntry: read.read<WeightEntryBloc>(),
      weightGoal: read.read<WeightGoalBloc>(),
    ),
  ),
];
