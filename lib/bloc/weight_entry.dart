import 'package:event_bloc/event_bloc.dart';
import 'package:event_db/event_db.dart';
import 'package:weight_blade/event/weight.dart';
import 'package:weight_blade/model/ledger.dart';
import 'package:weight_blade/model/weight.dart';

const weightDb = "WEIGHT";
const ledgerKey = "Ledger";

class WeightEntryBloc extends Bloc {
  final DatabaseRepository repo;

  Ledger? ledger;
  final loadedEntries = <String>[];
  final weightEntryMap = <String, WeightEntry>{};
  bool loading = false;

  WeightEntryBloc({required super.parentChannel, required this.repo}) {
    eventChannel.addEventListener(
        WeightEvent.loadLedger.event, (p0, p1) => loadLedger());
  }

  void loadLedger() async {
    if (loading) {
      return;
    }

    loading = true;
    updateBloc();
    ledger = await repo.findModel(weightDb, ledgerKey);
    loading = false;
    updateBloc();
  }

  void loadWeightEntries(int entriesToLoad) async {
    if (ledger == null) {
      return;
    }
    final loadedSet = loadedEntries.toSet();
    final entryKeys = ledger!.entries
        .where((element) => !loadedSet.contains(element))
        .take(entriesToLoad);

    // TODO Combine loading of values into one.
    final newLoadedEntries = await Future.wait(
        entryKeys.map((e) => repo.findModel<WeightEntry>(weightDb, e)));

    newLoadedEntries.where((element) => element != null).forEach((element) {
      loadedEntries.add(element!.id!);
      weightEntryMap[element.id!] = element;
    });

    loadedEntries.sort((a, b) =>
        weightEntryMap[b]!.dateTime.compareTo(weightEntryMap[a]!.dateTime));

    updateBloc();
  }
}
