import 'package:event_bloc/event_bloc.dart';
import 'package:weight_blade/model/weight.dart';

enum WeightEvent<T> {
  loadNWeightEntries<int>(),
  addWeightEntry<WeightEntry>(),
  updateWeightEntry<WeightEntry>(),
  deleteWeightEntry<WeightEntry>(),
  ensureDateTimeIsShown<DateTime>(),

  reset<void>(),
  showImportExportScreen<bool>(),
  ;

  BlocEventType<T> get event => BlocEventType.fromObject(this);
}
