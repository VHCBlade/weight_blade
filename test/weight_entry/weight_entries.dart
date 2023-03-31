import 'package:event_db/event_db.dart';
import 'package:weight_blade/bloc/goal.dart';
import 'package:weight_blade/model/ledger.dart';
import 'package:weight_blade/model/weight.dart';

/// Starts with Jan 1989 and ends with April 1997, each entry is a month apart.
Future<List<DateTime>> add100WeightEntries(DatabaseRepository repository,
    [String database = weightDb]) async {
  final ledger = Ledger()..id = ledgerKey;
  final list = <DateTime>[];
  for (int i = 0; i < 100; i++) {
    final model = await repository.saveModel(
        database,
        WeightEntry()
          ..dateTime = DateTime(1989, i + 1)
          ..weight = 300.0 - i);
    ledger.entries.insert(0, model.id!);
    list.insert(0, model.dateTime);
  }

  repository.saveModel(database, ledger);

  return list;
}
