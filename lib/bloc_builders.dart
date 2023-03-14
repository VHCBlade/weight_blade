import 'package:event_bloc/event_bloc_widgets.dart';
import 'package:event_db/event_db.dart';
import 'package:event_navigation/event_navigation.dart';
import 'package:weight_blade/bloc/ad.dart';
import 'package:weight_blade/bloc/goal.dart';
import 'package:weight_blade/bloc/navigation/navigation.dart';
import 'package:weight_blade/bloc/reminder.dart';
import 'package:weight_blade/bloc/settings/settings.dart';
import 'package:weight_blade/bloc/weight_entry.dart';
import 'package:weight_blade/repository/notifications/repo.dart';

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
  BlocBuilder<ReminderBloc>((read, channel) => ReminderBloc(
      parentChannel: channel,
      databaseRepository: read.read<DatabaseRepository>(),
      notificationsRepository: read.read<NotificationRepository>())),
  BlocBuilder<SettingsBloc>((read, channel) => SettingsBloc(
      parentChannel: channel,
      databaseRepository: read.read<DatabaseRepository>())),
  BlocBuilder<AdBloc>(
    (read, channel) => AdBloc(
        parentChannel: channel,
        repository: read.read<DatabaseRepository>(),
        settingsGetter: () => read.read<SettingsBloc>().settings),
  ),
];
