import 'package:event_bloc/event_bloc.dart';
import 'package:event_db/event_db.dart';
import 'package:uuid/uuid.dart';
import 'package:weight_blade/event/ledger.dart';
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

  bool get noEntries => ledger?.entries.isEmpty ?? true;

  WeightEntryBloc({required super.parentChannel, required this.repo}) {
    eventChannel.addEventListener(
        LedgerEvent.loadLedger.event, (p0, p1) => loadLedger());
    eventChannel.addEventListener<int>(WeightEvent.loadNWeightEntries.event,
        (p0, p1) => loadWeightEntries(p1));
    eventChannel.addEventListener<WeightEntry>(
        WeightEvent.addWeightEntry.event, (p0, p1) => addWeightEntry(p1));
    eventChannel.addEventListener<WeightEntry>(
        WeightEvent.updateWeightEntry.event, (p0, p1) => updateWeightEntry(p1));
    eventChannel.addEventListener<WeightEntry>(
        WeightEvent.deleteWeightEntry.event, (p0, p1) => deleteWeightEntry(p1));
  }

  WeightEntry? get latestEntry =>
      loadedEntries.isEmpty ? null : weightEntryMap[loadedEntries.first];

  WeightEntry? entryAt(int position) => loadedEntries.length <= position
      ? null
      : weightEntryMap[loadedEntries[position]];

  void loadLedger() async {
    if (loading) {
      return;
    }

    loading = true;
    updateBloc();
    ledger = await repo.findModel<Ledger>(weightDb, ledgerKey);
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

    // TODO WB-1 Combine loading of values into one.
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

  void addWeightEntry(WeightEntry entry) async {
    entry.id = const Uuid().v4();
    entry.dateTime = DateTime.now();

    loadedEntries.insert(0, entry.id!);
    weightEntryMap[entry.id!] = entry;

    ledger = ledger ?? Ledger()
      ..id = ledgerKey;

    ledger!.entries.insert(0, entry.id!);

    await repo.saveModel<WeightEntry>(weightDb, entry);
    await repo.saveModel<Ledger>(weightDb, ledger!);

    updateBloc();
  }

  void updateWeightEntry(WeightEntry entry) async {
    await repo.saveModel<WeightEntry>(weightDb, entry);
    weightEntryMap[entry.id!] = entry;

    updateBloc();
  }

  void deleteWeightEntry(WeightEntry entry) async {
    await repo.deleteModel<WeightEntry>(weightDb, entry);
    weightEntryMap[entry.id!] = entry;

    loadedEntries.remove(entry.id!);
    ledger!.entries.remove(entry.id!);
    await repo.saveModel<Ledger>(weightDb, ledger!);

    updateBloc();
  }
}
