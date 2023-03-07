import 'package:event_ads/event_ads.dart';
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
  RepositoryBuilder<AdRepository>((read) => AdRepository(
          adHandler: AdMobHandler(
        interstitialId: "ca-app-pub-1198511294368540/5873231445",
        rewardedId: "ca-app-pub-1198511294368540/5161988843",
      ))),
];
