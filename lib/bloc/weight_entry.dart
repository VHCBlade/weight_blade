import 'dart:async';

import 'package:event_bloc/event_bloc.dart';
import 'package:event_db/event_db.dart';
import 'package:tuple/tuple.dart';
import 'package:weight_blade/event/ledger.dart';
import 'package:weight_blade/event/weight.dart';
import 'package:weight_blade/model/ledger.dart';
import 'package:weight_blade/model/weight.dart';

const weightDb = "WEIGHT";
const ledgerKey = "Ledger";

class WeightEntryBloc extends Bloc {
  final DatabaseRepository database;
  final _addedWeight = StreamController<int>.broadcast();
  final _removedWeight = StreamController<Tuple2<int, WeightEntry>>.broadcast();

  Stream<int> get addedWeightIndex => _addedWeight.stream;
  Stream<Tuple2<int, WeightEntry>> get removedWeight => _removedWeight.stream;

  Ledger? ledger;
  final loadedEntries = <String>[];
  late final weightEntryMap = GenericModelMap<WeightEntry>(
      repository: () => database,
      supplier: WeightEntry.new,
      defaultDatabaseName: weightDb);
  bool loading = false;

  bool get noEntries => ledger?.entries.isEmpty ?? true;

  WeightEntryBloc({required super.parentChannel, required this.database}) {
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
    eventChannel.addEventListener<DateTime>(
        WeightEvent.ensureDateTimeIsShown.event,
        (p0, p1) => ensureDateTimeIsShown(p1));
  }

  @override
  void dispose() {
    super.dispose();
    _addedWeight.close();
    _removedWeight.close();
  }

  WeightEntry? get latestEntry =>
      loadedEntries.isEmpty ? null : weightEntryMap.map[loadedEntries.first];

  WeightEntry? get oldestLoadedEntry =>
      loadedEntries.isEmpty ? null : weightEntryMap.map[loadedEntries.last];

  WeightEntry? entryAt(int position) => loadedEntries.length <= position
      ? null
      : weightEntryMap.map[loadedEntries[position]];

  void loadLedger() async {
    if (loading) {
      return;
    }

    loading = true;
    updateBloc();
    ledger = await database.findModel<Ledger>(weightDb, ledgerKey);
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
    await database.saveModel<Ledger>(weightDb, ledger);
  }

  Future<void> ensureDateTimeIsShown(DateTime dateTime) async {
    while (loadedEntries.isEmpty ||
        dateTime.isBefore(oldestLoadedEntry!.dateTime)) {
      if (ledger == null || ledger!.entries.length <= loadedEntries.length) {
        return;
      }
      await loadWeightEntries(10);
    }
  }

  void sortEntriesByDate() =>
      loadedEntries.sort((a, b) => weightEntryMap.map[b]!.dateTime
          .compareTo(weightEntryMap.map[a]!.dateTime));

  Future<void> loadWeightEntries(int entriesToLoad) async {
    if (ledger == null) {
      return;
    }
    // print("Loading $entriesToLoad - "
    //     "Current ${loadedEntries.length} - Potential ${ledger?.entries.length}");
    final loadedSet = loadedEntries.toSet();
    final entryKeys = ledger!.entries
        .where((element) => !loadedSet.contains(element))
        .take(entriesToLoad);

    // TODO WB-1 Combine loading of values into one.
    final newLoadedEntries = await weightEntryMap.loadModelIds(entryKeys);

    newLoadedEntries.forEach((element) {
      loadedEntries.add(element.id!);
      _addedWeight.sink.add(loadedEntries.length - 1);
    });

    sortEntriesByDate();

    updateBloc();
  }

  void addWeightEntry(WeightEntry entry) async {
    final newEntry = await weightEntryMap.addModel(entry);
    loadedEntries.insert(0, newEntry.id!);

    ledger = ledger ?? Ledger()
      ..id = ledgerKey;

    ledger!.entries.insert(0, newEntry.id!);
    await ensureCorrectOrder(newEntry);

    _addedWeight.sink.add(loadedEntries.indexOf(newEntry.id!));
    await database.saveModel<Ledger>(weightDb, ledger!);

    updateBloc();
  }

  /// returns true if the [entry] was already in the correct place. false if the list had to be sorted first.
  Future<bool> ensureCorrectOrder(WeightEntry entry) async {
    if (entryIsAtCorrectLocation(entry)) {
      return true;
    }

    await ensureDateTimeIsShown(
        entry.dateTime.subtract(const Duration(seconds: 1)));

    sortEntriesByDate();
    ledger!.entries = [
      ...loadedEntries,
      ...ledger!.entries.sublist(loadedEntries.length)
    ];

    return false;
  }

  bool entryIsAtCorrectLocation(WeightEntry entry) {
    final location = loadedEntries.indexOf(entry.id!);

    if (location > 0 &&
        weightEntryMap.map[loadedEntries[location - 1]]!.dateTime
            .isBefore(entry.dateTime)) {
      return false;
    }

    return location + 1 < loadedEntries.length &&
        weightEntryMap.map[loadedEntries[location + 1]]!.dateTime
            .isBefore(entry.dateTime);
  }

  void updateWeightEntry(WeightEntry entry) async {
    await database.saveModel<WeightEntry>(weightDb, entry);
    weightEntryMap.map[entry.id!] = entry;
    final initialLocation = loadedEntries.indexOf(entry.id!);
    if (!await ensureCorrectOrder(entry)) {
      await database.saveModel<Ledger>(weightDb, ledger!);
      _removedWeight.add(Tuple2(initialLocation, entry));
      _addedWeight.add(loadedEntries.indexOf(entry.id!));
    }

    updateBloc();
  }

  void deleteWeightEntry(WeightEntry entry) async {
    if (!await weightEntryMap.deleteModel(entry)) {
      return;
    }

    final location = loadedEntries.indexOf(entry.id!);
    if (location >= 0) {
      loadedEntries.removeAt(location);
      _removedWeight.add(Tuple2(location, entry));
    }
    ledger!.entries.remove(entry.id!);
    await database.saveModel<Ledger>(weightDb, ledger!);

    updateBloc();
  }
}
