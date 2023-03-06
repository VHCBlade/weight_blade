import 'package:event_bloc/event_bloc_widgets.dart';
import 'package:weight_blade/model/settings.dart';

enum SettingsEvent<T> {
  loadSettings<void>(),
  saveSettings<WBSettings>(),
  ;

  BlocEventType<T> get event => BlocEventType.fromObject(this);
}
