import 'package:event_bloc/event_bloc.dart';
import 'package:event_db/event_db.dart';
import 'package:weight_blade/event/weight.dart';
import 'package:weight_blade/model/goal.dart';

const weightDb = "WEIGHT";
const ledgerKey = "Ledger";

class WeightGoalBloc extends Bloc {
  final DatabaseRepository repo;

  final weightGoalMap = <String, WeightGoal>{};

  WeightGoalBloc({required super.parentChannel, required this.repo}) {
    eventChannel.addEventListener<String?>(
        WeightEvent.loadWeightGoal.event, (p0, p1) => loadWeightGoal(p1));
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
}
