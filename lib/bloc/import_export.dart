import 'package:event_alert/event_alert_widgets.dart';
import 'package:event_bloc/event_bloc.dart';
import 'package:event_db/event_db.dart';
import 'package:weight_blade/event/weight.dart';
import 'package:weight_blade/model/weight.dart';

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
      );
  }

  bool loading = false;

  final DatabaseRepository database;

  bool showImportExportScreen = false;

  final List<WeightEntry> weightEntries = [];

  void setShowImportExportScreen(bool showImportExportScreen) {
    if (loading) {
      eventChannel.fireAlert('Please wait for the import/export to finish');
      return;
    }
    if (showImportExportScreen == this.showImportExportScreen) {
      return;
    }
    this.showImportExportScreen = showImportExportScreen;
    updateBloc();
    eventChannel.eventBus.fireEvent(WeightEvent.reset.event, null);
  }
}
