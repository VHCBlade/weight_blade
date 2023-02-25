import 'package:event_bloc/event_bloc.dart';
import 'package:weight_blade/model/ledger.dart';

enum LedgerEvent<T> {
  loadLedger<void>(),
  updateLedger<Ledger>(),
  updateGoal<String>(),
  ;

  BlocEventType<T> get event => BlocEventType.fromObject(this);
}
