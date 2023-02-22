import 'package:event_bloc/event_bloc.dart';
import 'package:weight_blade/model/weight.dart';

enum WeightEvent<T> {
  loadNWeightEntries<int>(),
  loadWeightGoal<String?>(),
  addWeightEntry<WeightEntry>(),
  updateWeightEntry<WeightEntry>(),
  ;

  BlocEventType<T> get event => BlocEventType.fromObject(this);
}
