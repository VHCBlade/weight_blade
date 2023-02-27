import 'package:event_bloc/event_bloc.dart';
import 'package:event_db/event_db.dart';
import 'package:weight_blade/bloc/weight_entry.dart';
import 'package:weight_blade/event/reminder.dart';
import 'package:weight_blade/model/reminder.dart';
import 'package:weight_blade/repository/notifications/repo.dart';

const _reminderId = "Reminder";

class ReminderBloc extends Bloc {
  final DatabaseRepository databaseRepository;
  final NotificationRepository notificationsRepository;
  Reminder? reminder;
  bool loading = false;

  ReminderBloc({
    required super.parentChannel,
    required this.databaseRepository,
    required this.notificationsRepository,
  }) {
    eventChannel.addEventListener<void>(
        ReminderEvent.loadReminder.event, (p0, p1) => loadReminder());
    eventChannel.addEventListener<Reminder>(
        ReminderEvent.updateReminder.event, (p0, p1) => updateReminder(p1));
    eventChannel.addEventListener<bool>(
        ReminderEvent.enableReminder.event, (p0, p1) => enableReminder(p1));
  }

  Future<void> loadReminder() async {
    if (loading) {
      return;
    }
    loading = true;
    updateBloc();
    reminder =
        await databaseRepository.findModel<Reminder>(weightDb, _reminderId);
    reminder ??= Reminder();
    loading = false;
    updateBloc();
  }

  Future<void> updateReminder(Reminder reminder) async {
    reminder.id = _reminderId;
    if (this.reminder?.enabled ?? false) {
      await notificationsRepository.disableNotifications(this.reminder);
    }
    this.reminder = reminder;
    updateBloc();

    await databaseRepository.saveModel<Reminder>(weightDb, reminder);
    if (reminder.enabled) {
      await notificationsRepository.enableNotifications();
      await notificationsRepository.setReminder(reminder);
    }
    updateBloc();
  }

  Future<void> enableReminder(bool enable) async {
    if (reminder == null) {
      return;
    }
    if (!enable) {
      reminder!.enabled = false;
      updateReminder(reminder!);
      return;
    }

    if (!(await notificationsRepository.enableNotifications())) {
      return;
    }
    reminder!.enabled = true;
    updateReminder(reminder!);
    return;
  }
}
