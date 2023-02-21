import 'package:event_bloc/event_bloc_widgets.dart';
import 'package:event_db/event_db.dart';
import 'package:event_hive/event_hive.dart';
import 'package:weight_blade/repository/database/hive.dart';

final pocRepositoryBuilders = [
  // RepositoryBuilder<ReviewerRepository>((read) => AssetReviewerRepository()),
  RepositoryBuilder<DatabaseRepository>(
      (read) => HiveRepository(typeAdapters: typeAdapters)),
];
