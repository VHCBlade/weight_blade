import 'package:event_bloc/event_bloc.dart';
import 'package:weight_blade/model/goal.dart';

enum GoalEvent<T> {
  loadWeightGoal<String?>(),
  addWeightGoal<WeightGoal>(),
  updateWeightGoal<WeightGoal>(),
  ;

  BlocEventType<T> get event => BlocEventType.fromObject(this);
}
