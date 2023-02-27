import 'package:event_bloc/event_bloc_widgets.dart';
import 'package:weight_blade/model/reminder.dart';

enum ReminderEvent<T> {
  loadReminder<void>(),
  updateReminder<Reminder>(),
  enableReminder<bool>(),
  ;

  BlocEventType<T> get event => BlocEventType.fromObject(this);
}
