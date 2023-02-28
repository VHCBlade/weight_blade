import 'package:event_bloc/event_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_native_timezone/flutter_native_timezone.dart';
import 'package:timezone/timezone.dart';
import 'package:weight_blade/model/reminder.dart';
import 'package:timezone/data/latest.dart';
import 'package:weight_blade/repository/notifications/model.dart';
import 'package:weight_blade/repository/notifications/repo.dart';

class LocalNotificationRepository extends NotificationRepository {
  late final FlutterLocalNotificationsPlugin plugin =
      FlutterLocalNotificationsPlugin();

  int idFromReminder(Reminder reminder, DayOfTheWeek day) {
    return "${reminder.id}${day.name}".hashCode;
  }

  @override
  Future<void> initialize(BlocEventChannel channel) async {
    initializeTimeZones();
    super.initialize(channel);
  }

  @override
  Future<bool> disableNotifications(Reminder? reminder) async {
    if (reminder == null) {
      return false;
    }

    for (final day in DayOfTheWeek.values) {
      await plugin.cancel(idFromReminder(reminder, day));
    }

    return true;
  }

  @override
  Future<bool> enableNotifications() async {
    const androidSettings =
        AndroidInitializationSettings('@mipmap/launcher_icon');
    const iosSettings = DarwinInitializationSettings();

    const settings =
        InitializationSettings(android: androidSettings, iOS: iosSettings);
    final initialized = await plugin.initialize(settings);

    return initialized ?? false;
  }

  @override
  Future<bool> setReminder(Reminder? reminder) async {
    if (reminder == null) {
      return false;
    }

    for (final day in reminder.daysOfTheWeek) {
      DateTime currentDay = DateTime.now();
      currentDay.weekday;
      plugin.zonedSchedule(
        idFromReminder(reminder, day),
        "Weigh-in Reminder",
        "Time to weigh in!",
        TZDateTime.from(getNextDayOfTheWeekAndTime(day, reminder.timeOfDay),
            getLocation(await FlutterNativeTimezone.getLocalTimezone())),
        const NotificationDetails(
            android: AndroidNotificationDetails(
          "Weekly Reminder",
          "Weekly Reminder",
          icon: '@mipmap/notification',
          importance: Importance.high,
          priority: Priority.high,
        )),
        androidAllowWhileIdle: true,
        matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.wallClockTime,
      );
    }

    return true;
  }

  DateTime getNextDayOfTheWeekAndTime(
      DayOfTheWeek dayOfTheWeek, TimeOfDay timeOfDay) {
    final currentDay = DateTime.now();
    final currentDaySetTime = currentDay.copyWith(
      microsecond: 0,
      millisecond: 0,
      second: 0,
      hour: timeOfDay.hour,
      minute: timeOfDay.minute,
    );

    final candidateDay = currentDaySetTime
        .add(Duration(days: currentDay.weekday - dayOfTheWeek.count % 7));

    return candidateDay.isBefore(currentDay)
        ? candidateDay.add(const Duration(days: 7))
        : candidateDay;
  }
}
