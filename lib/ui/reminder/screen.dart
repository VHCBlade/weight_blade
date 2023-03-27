import 'package:event_bloc/event_bloc_widgets.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:weight_blade/bloc/reminder.dart';
import 'package:weight_blade/event/reminder.dart';
import 'package:weight_blade/model/reminder.dart';
import 'package:weight_blade/repository/notifications/model.dart';

class ReminderScreen extends StatelessWidget {
  const ReminderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final bloc = context.watchBloc<ReminderBloc>();

    return Scaffold(
      appBar: AppBar(title: const Text("Reminders")),
      body: bloc.reminder == null
          ? const CupertinoActivityIndicator()
          : ListView(
              children: [
                const SizedBox(height: 20),
                ListTile(
                  title: const Text("Enable Reminders"),
                  trailing: CupertinoSwitch(
                      value: bloc.reminder!.enabled,
                      onChanged: (val) => context.fireEvent(
                          ReminderEvent.enableReminder.event, val)),
                ),
                const SizedBox(height: 20),
                // TODO: WB-20 This alarm option doesn't work. It always plays the alarm at the closest possible date.
                // ListTile(
                //   title: const Text("Play Alarm"),
                //   trailing: CupertinoSwitch(
                //       value: bloc.reminder!.enabledAlarm,
                //       onChanged: (val) => context.fireEvent(
                //           ReminderEvent.updateReminder.event,
                //           bloc.reminder!..enabledAlarm = val)),
                // ),
                ListTile(
                  title: const Text("Notification Time"),
                  trailing: ElevatedButton(
                      onPressed: () async {
                        final eventChannel = context.eventChannel;
                        final timeOfDay = await showTimePicker(
                            context: context,
                            initialTime: bloc.reminder!.timeOfDay,
                            builder: (_, child) => TimePickerTheme(
                                data: TimePickerTheme.of(context).copyWith(
                                    backgroundColor: Theme.of(context)
                                        .scaffoldBackgroundColor),
                                child: child ?? Container()));

                        if (timeOfDay == null) {
                          return;
                        }

                        eventChannel.fireEvent<Reminder>(
                            ReminderEvent.updateReminder.event,
                            bloc.reminder!..timeOfDay = timeOfDay);
                      },
                      child: Text(bloc.reminder!.timeOfDay.format(context))),
                ),
                ListTile(
                  title: const Text("Reminder Days"),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 5),
                    child: Wrap(
                        spacing: 5,
                        children: DayOfTheWeek.values
                            .map((e) => ReminderDayWidget(
                                reminder: bloc.reminder!, day: e))
                            .toList()),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
    );
  }
}

class ReminderDayWidget extends StatelessWidget {
  final Reminder reminder;
  final DayOfTheWeek day;

  const ReminderDayWidget(
      {super.key, required this.reminder, required this.day});

  @override
  Widget build(BuildContext context) {
    if (reminder.daysOfTheWeek.contains(day)) {
      return ElevatedButton(
          onPressed: () => context.fireEvent<Reminder>(
              ReminderEvent.updateReminder.event,
              reminder..daysOfTheWeek.remove(day)),
          child: Text(day.displayName));
    }
    return OutlinedButton(
        onPressed: () => context.fireEvent<Reminder>(
            ReminderEvent.updateReminder.event,
            reminder..daysOfTheWeek.add(day)),
        child: Text(day.displayName));
  }
}
