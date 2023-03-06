import 'package:event_bloc/event_bloc_widgets.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:weight_blade/bloc/settings/settings.dart';
import 'package:weight_blade/model/settings.dart';

extension BuildContextExtension on BuildContext {
  WBSettings get readSettings =>
      read<SettingsBloc?>()?.settings ?? WBSettingsModel();
  WBSettings get watchSettings => watchBloc<SettingsBloc>().settings;
}
