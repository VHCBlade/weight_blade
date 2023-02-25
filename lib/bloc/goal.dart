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
    eventChannel.addEventListener<WeightGoal>(
        GoalEvent.updateWeightGoal.event, (p0, p1) => updateWeightGoal(p1));
  }

  void loadWeightGoal(String? id) async {
    if (id == null) {
      return;
    }
    final goal = await repo.findModel<WeightGoal>(weightDb, ledgerKey);
    if (goal == null) {
      return;
    }
    weightGoalMap[id] = goal;
    updateBloc();
  }

  void updateWeightGoal(WeightGoal weightGoal) async {
    weightGoal.id ??= const Uuid().v4();
    await repo.saveModel<WeightGoal>(weightDb, weightGoal);
    weightGoalMap[weightGoal.id!] = weightGoal;
    updateBloc();
  }
}

class WeightGoalWatcherBloc extends Bloc {
  final WeightGoalBloc weightGoal;
  final WeightEntryBloc weightEntry;

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
    super.dispose();
  }
}
