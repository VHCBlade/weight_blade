import 'dart:async';

import 'package:event_bloc/event_bloc.dart';
import 'package:event_db/event_db.dart';
import 'package:tuple/tuple.dart';
import 'package:uuid/uuid.dart';
import 'package:weight_blade/event/ledger.dart';
import 'package:weight_blade/event/weight.dart';
import 'package:weight_blade/model/ledger.dart';
import 'package:weight_blade/model/weight.dart';

const weightDb = "WEIGHT";
const ledgerKey = "Ledger";

class WeightEntryBloc extends Bloc {
  final DatabaseRepository repo;
  final _addedWeight = StreamController<int>.broadcast();
  final _removedWeight = StreamController<Tuple2<int, WeightEntry>>.broadcast();

  Stream<int> get addedWeightIndex => _addedWeight.stream;
  Stream<Tuple2<int, WeightEntry>> get removedWeight => _removedWeight.stream;

  Ledger? ledger;
  final loadedEntries = <String>[];
  final weightEntryMap = <String, WeightEntry>{};
  bool loading = false;

  bool get noEntries => ledger?.entries.isEmpty ?? true;

  WeightEntryBloc({required super.parentChannel, required this.repo}) {
    eventChannel.addEventListener<void>(
        LedgerEvent.loadLedger.event, (p0, p1) => loadLedger());
    eventChannel.addEventListener<Ledger>(
        LedgerEvent.updateLedger.event, (p0, p1) => updateLedger(p1));
    eventChannel.addEventListener<String>(
        LedgerEvent.updateGoal.event, (p0, p1) => updateLedgerGoal(p1));

    eventChannel.addEventListener<int>(WeightEvent.loadNWeightEntries.event,
        (p0, p1) => loadWeightEntries(p1));
    eventChannel.addEventListener<WeightEntry>(
        WeightEvent.addWeightEntry.event, (p0, p1) => addWeightEntry(p1));
    eventChannel.addEventListener<WeightEntry>(
        WeightEvent.updateWeightEntry.event, (p0, p1) => updateWeightEntry(p1));
    eventChannel.addEventListener<WeightEntry>(
        WeightEvent.deleteWeightEntry.event, (p0, p1) => deleteWeightEntry(p1));
  }

  @override
  void dispose() {
    super.dispose();
    _addedWeight.close();
    _removedWeight.close();
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

  void updateLedgerGoal(String goal) async {
    if (ledger == null) {
      return;
    }
    updateLedger(ledger!..currentWeightGoal = goal);
  }

  void updateLedger(Ledger ledger) async {
    ledger.id = ledgerKey;
    this.ledger = ledger;
    updateBloc();
    await repo.saveModel<Ledger>(weightDb, ledger);
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
    _addedWeight.sink.add(0);
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

    final location = loadedEntries.indexOf(entry.id!);
    if (location >= 0) {
      loadedEntries.removeAt(location);
      _removedWeight.add(Tuple2(location, entry));
    }
    ledger!.entries.remove(entry.id!);
    await repo.saveModel<Ledger>(weightDb, ledger!);

    updateBloc();
  }
}
