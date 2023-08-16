import 'package:alarm/alarm.dart';
import 'package:event_bloc/event_bloc.dart';
import 'package:weight_blade/model/reminder.dart';
import 'package:weight_blade/repository/notifications/model.dart';
import 'package:weight_blade/repository/notifications/repo.dart';

class AlarmNotificationRepository extends NotificationRepository {
  final NotificationRepository? wrapped;

  AlarmNotificationRepository(this.wrapped);

  @override
  Future<void> initialize(BlocEventChannel channel) async {
    await Alarm.init();
    super.initialize(channel);
  }

  Future<bool> _disableAlarms() async {
    await Future.wait(
        Alarm.getAlarms().map((element) => Alarm.stop(element.id)));
    return true;
  }

  @override
  Future<bool> disableNotifications(Reminder? reminder) async {
    await _disableAlarms();
    return await wrapped?.disableNotifications(reminder) ?? true;
  }

  @override
  Future<bool> enableNotifications() async {
    return await wrapped?.enableNotifications() ?? true;
  }

  int idFromReminder(Reminder reminder, DayOfTheWeek day) {
    return "${reminder.id}${day.name}".hashCode;
  }

  @override
  Future<bool> setReminder(Reminder? reminder) async {
    final enabledAlarm = reminder?.enabledAlarm ?? false;
    if (!enabledAlarm) {
      await _disableAlarms();
      return await wrapped?.setReminder(reminder) ?? true;
    }
    await wrapped?.disableNotifications(reminder);
    for (final day in {...reminder!.daysOfTheWeek}) {
      final nextTime = day.getNextTime(reminder.timeOfDay);
      await Alarm.set(
        alarmSettings: AlarmSettings(
          id: day.count + 100,
          dateTime: nextTime,
          notificationTitle: "Weigh-in Reminder",
          notificationBody: "Time to weigh in!",
          fadeDuration: 20,
          assetAudioPath: "assets/music/c-chord.mp4",
          loopAudio: false,
        ),
      );
    }
    return true;
  }
}
