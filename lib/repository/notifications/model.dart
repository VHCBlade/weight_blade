import 'package:flutter/material.dart';

enum DayOfTheWeek {
  mon("Monday", 1),
  tue("Tuesday", 2),
  wed("Wednesday", 3),
  thu("Thursday", 4),
  fri("Friday", 5),
  sat("Saturday", 6),
  sun("Sunday", 7),
  ;

  final String displayName;
  final int count;

  const DayOfTheWeek(this.displayName, this.count);

  DateTime getNextTime(TimeOfDay timeOfDay) {
    final currentDay = DateTime.now();
    final currentDaySetTime = currentDay.copyWith(
      microsecond: 0,
      millisecond: 0,
      second: 0,
      hour: timeOfDay.hour,
      minute: timeOfDay.minute,
    );

    final candidateDay =
        currentDaySetTime.add(Duration(days: (count - currentDay.weekday) % 7));

    return candidateDay.isBefore(currentDay)
        ? candidateDay.add(const Duration(days: 7))
        : candidateDay;
  }
}
