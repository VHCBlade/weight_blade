import 'package:event_bloc/event_bloc.dart';

enum LedgerEvent<T> {
  loadLedger<void>(),
  ;

  BlocEventType<T> get event => BlocEventType.fromObject(this);
}
