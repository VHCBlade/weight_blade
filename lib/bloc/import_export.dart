import 'dart:convert';

import 'package:event_alert/event_alert_widgets.dart';
import 'package:event_bloc/event_bloc.dart';
import 'package:event_db/event_db.dart';
import 'package:weight_blade/bloc/goal.dart';
import 'package:weight_blade/event/weight.dart';
import 'package:weight_blade/model/ledger.dart';
import 'package:weight_blade/model/weight.dart';

enum ImportExportState {
  idle('idle'),
  importing('import'),
  exporting('export'),
  ;

  const ImportExportState(this.action);

  final String action;
}

class ImportExportBloc extends Bloc {
  ImportExportBloc({required super.parentChannel, required this.database}) {
    eventChannel
      ..addEventBusListener(
        WeightEvent.reset.event,
        (event, value) => weightEntries.clear(),
      )
      ..addEventListener(
        WeightEvent.showImportExportScreen.event,
        (event, value) => setShowImportExportScreen(value),
      )
      ..addEventListener(
          WeightEvent.export.event, (event, value) => exportJson())
      ..addEventListener(
          WeightEvent.finishExport.event, (event, value) => finishExport())
      ..addEventListener(
          WeightEvent.finishImport.event, (event, value) => finishImport())
      ..addEventListener(
          WeightEvent.startImport.event, (event, value) => startImport())
      ..addEventListener(
          WeightEvent.import.event, (event, value) => importJson(value));
  }

  ImportExportState state = ImportExportState.idle;

  final DatabaseRepository database;
  late final specificDb = SpecificDatabase(database, weightDb);

  bool showImportExportScreen = false;

  final List<WeightEntry> weightEntries = [];

  void setShowImportExportScreen(bool showImportExportScreen) {
    if (state != ImportExportState.idle) {
      eventChannel.fireAlert('Please wait for the ${state.action} to finish.');
      return;
    }
    if (showImportExportScreen == this.showImportExportScreen) {
      return;
    }
    this.showImportExportScreen = showImportExportScreen;
    updateBloc();
    eventChannel.eventBus.fireEvent(WeightEvent.reset.event, null);
  }

  void exportJson() async {
    if (state != ImportExportState.idle) {
      return;
    }
    state = ImportExportState.exporting;
    updateBloc();

    final ledger = await specificDb.findModel<Ledger>(ledgerKey);

    weightEntries.addAll(await specificDb.findAllModelsOfType(WeightEntry.new));

    if (ledger != null && weightEntries.length < ledger.entries.length) {
      updateIdOfOldWeightEntries(ledger);
    }

    final encodedJson =
        json.encode(weightEntries.map((e) => e.toMap()).toList());

    eventChannel.eventBus.fireEvent(
      WeightEvent.exportedJson.event,
      encodedJson,
    );
    weightEntries.clear();
  }

  Future<void> updateIdOfOldWeightEntries(Ledger ledger) async {
    weightEntries.clear();
    final currentWeightEntries = await specificDb.findModels(ledger.entries);

    final newWeightEntries = await Future.wait(
      currentWeightEntries.map(
        (e) async {
          specificDb.deleteModel(e);
          return e..idSuffix = e.idSuffix;
        },
      ),
    );
    await specificDb.saveModels(newWeightEntries);
    await reorderLedger(ledger);
  }

  Future<void> reorderLedger(Ledger ledger) async {
    weightEntries.addAll(
        (await database.findAllModelsOfType(weightDb, WeightEntry.new)));
    weightEntries.sort((a, b) => b.dateTime.compareTo(a.dateTime));
    ledger.entries
      ..clear()
      ..addAll([...weightEntries.map((e) => e.id!)]);

    await specificDb.saveModel(ledger);
  }

  void finishExport() {
    if (state != ImportExportState.exporting) {
      return;
    }
    state = ImportExportState.idle;
    weightEntries.clear();
    updateBloc();
  }

  void finishImport() {
    if (state != ImportExportState.importing) {
      return;
    }
    state = ImportExportState.idle;
    weightEntries.clear();
    updateBloc();
  }

  void startImport() {
    if (state != ImportExportState.idle) {
      return;
    }
    state = ImportExportState.importing;
    weightEntries.clear();
    updateBloc();
  }

  void importJson(String jsonString) async {
    if (state != ImportExportState.importing) {
      return;
    }

    try {
      final weightLogsMap = json.decode(jsonString) as List<dynamic>;
      final weightLogs =
          weightLogsMap.map((e) => WeightEntry()..loadFromMap(e));
      await database.saveModels(weightDb, weightLogs);
      final ledger =
          (await database.findModel<Ledger>(weightDb, ledgerKey)) ?? Ledger()
            ..id = ledgerKey;
      await reorderLedger(ledger);

      eventChannel.fireAlert('Finished Importing Weight Entries!');
    } on Object {
      eventChannel
          .fireError('There was an issue importing the Weight Entries!');
    } finally {
      weightEntries.clear();
      state = ImportExportState.idle;
      updateBloc();
    }
  }
}
