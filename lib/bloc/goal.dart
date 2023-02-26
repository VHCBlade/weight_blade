import 'dart:async';

import 'package:event_bloc/event_bloc.dart';
import 'package:event_db/event_db.dart';
import 'package:uuid/uuid.dart';
import 'package:weight_blade/bloc/weight_entry.dart';
import 'package:weight_blade/event/goal.dart';
import 'package:weight_blade/event/ledger.dart';
import 'package:weight_blade/model/goal.dart';
import 'package:weight_blade/model/weight.dart';

const weightDb = "WEIGHT";
const ledgerKey = "Ledger";

class WeightGoalBloc extends Bloc {
  final DatabaseRepository repo;

  final weightGoalMap = <String, WeightGoal>{};

  WeightGoalBloc({required super.parentChannel, required this.repo}) {
    eventChannel.addEventListener<String?>(
        GoalEvent.loadWeightGoal.event, (p0, p1) => loadWeightGoal(p1));
    eventChannel.addEventListener<WeightGoal>(
        GoalEvent.addWeightGoal.event, (p0, p1) => updateWeightGoal(p1));
    eventChannel.addEventListener<WeightGoal>(GoalEvent.updateWeightGoal.event,
        (p0, p1) => updateWeightGoal(p1, false));
  }

  void loadWeightGoal(String? id) async {
    if (id == null) {
      return;
    }
    final goal = await repo.findModel<WeightGoal>(weightDb, id);
    if (goal == null) {
      return;
    }
    weightGoalMap[id] = goal;
    updateBloc();
  }

  void updateWeightGoal(WeightGoal weightGoal,
      [bool setAsCurrentGoal = true]) async {
    weightGoal.id ??= const Uuid().v4();
    weightGoalMap[weightGoal.id!] = weightGoal;
    print(setAsCurrentGoal);
    if (setAsCurrentGoal) {
      eventChannel.fireEvent<String>(
          LedgerEvent.updateGoal.event, weightGoal.id!);
    }
    updateBloc();
    await repo.saveModel<WeightGoal>(weightDb, weightGoal);
  }
}

class WeightGoalWatcherBloc extends Bloc {
  final WeightGoalBloc weightGoal;
  final WeightEntryBloc weightEntry;

  late final _finishedGoal = StreamController<WeightGoal>.broadcast();

  Stream<WeightGoal> get finishedGoal => _finishedGoal.stream;

  WeightGoal? get goal =>
      weightGoal.weightGoalMap[weightEntry.ledger?.currentWeightGoal];

  WeightEntry? get latestWeight => weightEntry.latestEntry;

  double? get weightToGoal =>
      latestWeight == null ? null : goal?.difference(latestWeight!);

  void _update() {
    if (goal == null) {
      return;
    }
    if (latestWeight == null) {
      updateBloc();
      return;
    }
    if (!goal!.isAccomplishedBy(latestWeight!)) {
      updateBloc();
      return;
    }

    final ledger = weightEntry.ledger!;
    final currentGoal = goal!;
    ledger.currentWeightGoal = null;
    currentGoal.dateAccomplished = DateTime.now();

    eventChannel.fireEvent(LedgerEvent.updateLedger.event, ledger);
    eventChannel.fireEvent(GoalEvent.updateWeightGoal.event, currentGoal);
    _finishedGoal.sink.add(currentGoal);
    updateBloc();
  }

  WeightGoalWatcherBloc({
    required super.parentChannel,
    required this.weightGoal,
    required this.weightEntry,
  }) {
    weightGoal.blocUpdated.add(_update);
    weightEntry.blocUpdated.add(_update);
  }

  @override
  void dispose() {
    weightGoal.blocUpdated.remove(_update);
    weightEntry.blocUpdated.remove(_update);
    _finishedGoal.close();
    super.dispose();
  }
}
