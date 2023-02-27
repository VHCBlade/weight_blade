import 'package:event_db/event_db.dart';
import 'package:flutter/material.dart';
import 'package:tuple/tuple.dart';
import 'package:weight_blade/repository/notifications/model.dart';

class Reminder extends GenericModel {
  TimeOfDay timeOfDay = const TimeOfDay(hour: 7, minute: 0);
  Set<DayOfTheWeek> daysOfTheWeek = {DayOfTheWeek.sat, DayOfTheWeek.wed};
  bool enabled = false;

  @override
  Map<String, Tuple2<Getter, Setter>> getGetterSetterMap() => {
        "time": Tuple2(
            () => "${timeOfDay.hour}:${timeOfDay.minute}",
            (val) => timeOfDay = TimeOfDay(
                hour: int.parse(val.split(":")[0]),
                minute: int.parse(val.split(":")[1]))),
        "daysOfTheWeek": Tuple2(
            () => daysOfTheWeek.map((e) => e.name).toList(),
            (val) => daysOfTheWeek =
                val.map<DayOfTheWeek>((e) => daysOfTheWeek.byName(e)).toSet()),
        "enabled": Tuple2(() => enabled, (val) => enabled = val),
      };

  @override
  String get type => "Reminder";
}
