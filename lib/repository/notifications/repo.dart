import 'package:event_bloc/event_bloc.dart';
import 'package:weight_blade/model/reminder.dart';

abstract class NotificationRepository extends Repository {
  @override
  List<BlocEventListener> generateListeners(BlocEventChannel channel) => [];
  Future<bool> enableNotifications();
  Future<bool> setReminder(Reminder? reminder);
  Future<bool> disableNotifications(Reminder? reminder);
}

class FakeNotificationsRepository extends NotificationRepository {
  @override
  Future<bool> enableNotifications() async {
    return true;
  }

  @override
  Future<bool> disableNotifications(Reminder? reminder) async {
    return true;
  }

  @override
  Future<bool> setReminder(Reminder? reminder) async {
    return true;
  }
}
