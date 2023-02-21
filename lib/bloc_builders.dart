import 'package:event_bloc/event_bloc_widgets.dart';
import 'package:event_navigation/event_navigation.dart';
import 'package:weight_blade/bloc/navigation/navigation.dart';

final blocBuilders = [
  BlocBuilder<MainNavigationBloc<String>>(
      (read, channel) => generateNavigationBloc(parentChannel: channel)),
];
