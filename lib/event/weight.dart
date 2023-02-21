import 'package:event_bloc/event_bloc.dart';

enum WeightEvent<T> {
  loadLedger<void>(),
  loadNWeightEntries<int>(),
  ;

  BlocEventType<T> get event => BlocEventType.fromObject(this);
}
