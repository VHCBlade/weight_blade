import 'package:event_ads/event_ads.dart';
import 'package:event_bloc/event_bloc_widgets.dart';
import 'package:event_db/event_db.dart';
import 'package:event_essay/event_essay.dart';
import 'package:event_hive/event_hive.dart';
import 'package:flutter/foundation.dart';
import 'package:weight_blade/repository/database/hive.dart';
import 'package:weight_blade/repository/notifications/alarm_notifications.dart';
import 'package:weight_blade/repository/notifications/local_notifications.dart';
import 'package:weight_blade/repository/notifications/repo.dart';
import 'package:weight_blade/repository/url.dart';

final pocRepositoryBuilders = [
  RepositoryBuilder<DatabaseRepository>(
      (read) => HiveRepository(typeAdapters: typeAdapters)),
  RepositoryBuilder<NotificationRepository>((read) => kIsWeb
      ? FakeNotificationsRepository()
      : AlarmNotificationRepository(LocalNotificationRepository())),
  RepositoryBuilder<TextRepository>((read) => DefaultTextRepository()),
  RepositoryBuilder<UrlRepository>((read) => UrlRepository()),
  RepositoryBuilder<AdRepository>(
    (read) => AdRepository(
      adHandler: AdMobHandler(
        interstitialId: "ca-app-pub-1198511294368540/5873231445",
        rewardedId: "ca-app-pub-1198511294368540/5161988843",
      ),
    ),
  ),
];

final fakeRepositoryBuilders = [
  RepositoryBuilder<DatabaseRepository>((read) =>
      FakeDatabaseRepository(constructors: {
        for (var val in typeAdapters) val.instance.runtimeType: val.generator
      })),
  RepositoryBuilder<NotificationRepository>(
      (read) => FakeNotificationsRepository()),
  // TODO Add the other repositories here.
];
