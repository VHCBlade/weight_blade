import 'package:event_bloc/event_bloc_widgets.dart';
import 'package:event_db/event_db.dart';
import 'package:event_hive/event_hive.dart';
import 'package:flutter/foundation.dart';
import 'package:weight_blade/repository/database/hive.dart';
import 'package:weight_blade/repository/notifications/local_notifications.dart';
import 'package:weight_blade/repository/notifications/repo.dart';

final pocRepositoryBuilders = [
  RepositoryBuilder<DatabaseRepository>(
      (read) => HiveRepository(typeAdapters: typeAdapters)),
  RepositoryBuilder<NotificationRepository>((read) =>
      kIsWeb ? FakeNotificationsRepository() : LocalNotificationRepository()),
];
