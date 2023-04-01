import 'package:event_db/event_db.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:weight_blade/bloc/weight_entry.dart';
import 'package:weight_blade/event/ledger.dart';
import 'package:weight_blade/event/weight.dart';
import 'package:weight_blade/model/ledger.dart';
import 'package:weight_blade/model/weight.dart';

import 'weight_entries.dart';

void main() {
  group("Weight Entry Bloc", () {
    test("Load", loadEntriesTest);
    test("Ensure DateTime is Shown", ensureDateTimeIsShownTest);
    test("New Weight Entry Added", newWeightEntryAddedTest);
    test("Old Weight Entry Added", oldWeightEntryAddedTest);
    test("Delete", deleteTest);
  });
}

void deleteTest() async {
  final repository = FakeDatabaseRepository(
      constructors: {WeightEntry: WeightEntry.new, Ledger: Ledger.new});

  final bloc = WeightEntryBloc(parentChannel: null, database: repository);
  await add100WeightEntries(repository);

  bloc.eventChannel.fireEvent(LedgerEvent.loadLedger.event, null);
  await Future.delayed(Duration.zero);
  bloc.eventChannel.fireEvent(WeightEvent.loadNWeightEntries.event, 20);
  await Future.delayed(Duration.zero);
  bloc.eventChannel
      .fireEvent(WeightEvent.deleteWeightEntry.event, bloc.latestEntry!);
  await Future.delayed(Duration.zero);
  bloc.eventChannel
      .fireEvent(WeightEvent.deleteWeightEntry.event, bloc.oldestLoadedEntry!);
  await Future.delayed(Duration.zero);

  expect(bloc.loadedEntries.length, 18);
  bloc.eventChannel
      .fireEvent(WeightEvent.deleteWeightEntry.event, bloc.entryAt(5)!);
  await Future.delayed(Duration.zero);
  expect(bloc.loadedEntries.length, 17);

  final differentBloc =
      WeightEntryBloc(parentChannel: null, database: repository);

  differentBloc.eventChannel.fireEvent(LedgerEvent.loadLedger.event, null);
  await Future.delayed(Duration.zero);
  differentBloc.eventChannel
      .fireEvent(WeightEvent.loadNWeightEntries.event, 100);
  await Future.delayed(Duration.zero);

  expect(differentBloc.loadedEntries.length, 97);
}

void oldWeightEntryAddedTest() async {
  final repository = FakeDatabaseRepository(
      constructors: {WeightEntry: WeightEntry.new, Ledger: Ledger.new});

  final bloc = WeightEntryBloc(parentChannel: null, database: repository);
  final dates = await add100WeightEntries(repository);

  bloc.eventChannel.fireEvent(LedgerEvent.loadLedger.event, null);
  await Future.delayed(Duration.zero);
  bloc.eventChannel.fireEvent(WeightEvent.loadNWeightEntries.event, 20);
  await Future.delayed(Duration.zero);
  bloc.eventChannel.fireEvent(
      WeightEvent.addWeightEntry.event,
      WeightEntry()
        ..weight = 200
        ..dateTime = DateTime(1997, 3, 5));
  dates.insert(1, DateTime(1997, 3, 5));
  await Future.delayed(Duration.zero);

  expect(bloc.loadedEntries.map((e) => bloc.weightEntryMap.map[e]!.dateTime),
      dates.take(21));

  bloc.eventChannel.fireEvent(
      WeightEvent.addWeightEntry.event,
      WeightEntry()
        ..weight = 200
        ..dateTime = DateTime(1993, 1, 5));
  await Future.delayed(Duration.zero);
  dates.insert(52, DateTime(1993, 1, 5));
  expect(bloc.loadedEntries.map((e) => bloc.weightEntryMap.map[e]!.dateTime),
      dates.take(62));

  bloc.eventChannel.fireEvent(
      WeightEvent.addWeightEntry.event,
      WeightEntry()
        ..weight = 200
        ..dateTime = DateTime(1970, 1, 5));
  await Future.delayed(Duration.zero);
  dates.add(DateTime(1970, 1, 5));
  expect(bloc.loadedEntries.map((e) => bloc.weightEntryMap.map[e]!.dateTime),
      dates);

  final differentBloc =
      WeightEntryBloc(parentChannel: null, database: repository);
  differentBloc.eventChannel.fireEvent(LedgerEvent.loadLedger.event, null);
  await Future.delayed(Duration.zero);
  differentBloc.eventChannel
      .fireEvent(WeightEvent.loadNWeightEntries.event, 1000);
  await Future.delayed(Duration.zero);
  expect(
      differentBloc.loadedEntries
          .map((e) => bloc.weightEntryMap.map[e]!.dateTime),
      dates);
}

void newWeightEntryAddedTest() async {
  final repository = FakeDatabaseRepository(
      constructors: {WeightEntry: WeightEntry.new, Ledger: Ledger.new});

  final bloc = WeightEntryBloc(parentChannel: null, database: repository);

  bloc.eventChannel.fireEvent(LedgerEvent.loadLedger.event, null);
  await Future.delayed(Duration.zero);
  bloc.eventChannel
      .fireEvent(WeightEvent.addWeightEntry.event, WeightEntry()..weight = 200);
  await Future.delayed(Duration.zero);
  bloc.eventChannel
      .fireEvent(WeightEvent.addWeightEntry.event, WeightEntry()..weight = 210);
  await Future.delayed(Duration.zero);
  bloc.eventChannel
      .fireEvent(WeightEvent.addWeightEntry.event, WeightEntry()..weight = 220);
  await Future.delayed(Duration.zero);

  expect(bloc.loadedEntries.length, 3);
  expect(bloc.latestEntry!.weight, 220);
  expect(bloc.oldestLoadedEntry!.weight, 200);

  final differentBloc =
      WeightEntryBloc(parentChannel: null, database: repository);

  differentBloc.eventChannel.fireEvent(LedgerEvent.loadLedger.event, null);
  await Future.delayed(Duration.zero);
  differentBloc.eventChannel
      .fireEvent(WeightEvent.loadNWeightEntries.event, 20);
  await Future.delayed(Duration.zero);

  expect(differentBloc.latestEntry!.weight, 220);
  expect(differentBloc.entryAt(1)!.weight, 210);
  expect(differentBloc.oldestLoadedEntry!.weight, 200);
}

void ensureDateTimeIsShownTest() async {
  final repository = FakeDatabaseRepository(
      constructors: {WeightEntry: WeightEntry.new, Ledger: Ledger.new});

  final bloc = WeightEntryBloc(parentChannel: null, database: repository);

  final dates = await add100WeightEntries(repository);

  bloc.eventChannel.fireEvent(LedgerEvent.loadLedger.event, null);
  await Future.delayed(Duration.zero);
  bloc.eventChannel.fireEvent(WeightEvent.loadNWeightEntries.event, 20);
  await Future.delayed(Duration.zero);
  bloc.eventChannel
      .fireEvent(WeightEvent.ensureDateTimeIsShown.event, DateTime(1997, 1));
  await Future.delayed(Duration.zero);
  expect(bloc.loadedEntries.map((e) => bloc.weightEntryMap.map[e]!.dateTime),
      dates.take(20));

  bloc.eventChannel
      .fireEvent(WeightEvent.ensureDateTimeIsShown.event, DateTime(1993, 1));
  await Future.delayed(Duration.zero);
  expect(bloc.loadedEntries.map((e) => bloc.weightEntryMap.map[e]!.dateTime),
      dates.take(60));

  bloc.eventChannel
      .fireEvent(WeightEvent.ensureDateTimeIsShown.event, DateTime(1970, 1));
  await Future.delayed(Duration.zero);
  expect(bloc.loadedEntries.map((e) => bloc.weightEntryMap.map[e]!.dateTime),
      dates);
}

void loadEntriesTest() async {
  final repository = FakeDatabaseRepository(
      constructors: {WeightEntry: WeightEntry.new, Ledger: Ledger.new});

  final bloc = WeightEntryBloc(parentChannel: null, database: repository);

  final dates = await add100WeightEntries(repository);

  bloc.eventChannel.fireEvent(WeightEvent.loadNWeightEntries.event, 20);
  await Future.delayed(Duration.zero);
  expect(bloc.loadedEntries, []);

  bloc.eventChannel.fireEvent(LedgerEvent.loadLedger.event, null);
  await Future.delayed(Duration.zero);
  bloc.eventChannel.fireEvent(WeightEvent.loadNWeightEntries.event, 20);
  await Future.delayed(Duration.zero);
  expect(bloc.loadedEntries.map((e) => bloc.weightEntryMap.map[e]!.dateTime),
      dates.take(20));

  bloc.eventChannel.fireEvent(WeightEvent.loadNWeightEntries.event, 50);
  await Future.delayed(Duration.zero);
  expect(bloc.loadedEntries.map((e) => bloc.weightEntryMap.map[e]!.dateTime),
      dates.take(70));

  bloc.eventChannel.fireEvent(WeightEvent.loadNWeightEntries.event, 50);
  await Future.delayed(Duration.zero);
  expect(bloc.loadedEntries.map((e) => bloc.weightEntryMap.map[e]!.dateTime),
      dates);
}
