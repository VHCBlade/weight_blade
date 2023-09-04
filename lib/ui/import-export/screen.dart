import 'dart:convert';
import 'dart:typed_data';
import 'dart:io' show Platform;

import 'package:event_alert/event_alert_widgets.dart';
import 'package:event_bloc/event_bloc_widgets.dart';
import 'package:file_picker/file_picker.dart';
import 'package:file_saver/file_saver.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:weight_blade/bloc/import_export.dart';
import 'package:weight_blade/event/weight.dart';

final _dateFormatter = DateFormat('yyyy-MM-dd');

class ImportExportScreen extends StatefulWidget {
  const ImportExportScreen({super.key});

  @override
  State<ImportExportScreen> createState() => _ImportExportScreenState();
}

class _ImportExportScreenState extends State<ImportExportScreen> {
  late final BlocEventListener<dynamic> listener;

  void finishExport(String jsonString) async {
    final eventChannel = context.eventChannel;
    final filePath = Platform.isAndroid ? '/storage/emulated/0/Download' : null;
    try {
      if (Platform.isAndroid || Platform.isIOS) {
        final result = await FileSaver.instance.saveAs(
          name: '${_dateFormatter.format(DateTime.now())}-weight-entries',
          ext: 'json',
          mimeType: MimeType.json,
          bytes: Uint8List.fromList(utf8.encode(jsonString)),
          filePath: filePath,
        );

        if (result == null) {
          return;
        }
      } else {
        await FileSaver.instance.saveFile(
          name: '${_dateFormatter.format(DateTime.now())}-weight-entries',
          ext: 'json',
          mimeType: MimeType.json,
          bytes: Uint8List.fromList(utf8.encode(jsonString)),
          filePath: filePath,
        );
      }

      eventChannel.fireAlert(
        'Successfully Exported Weight Entries!\n\nTransfer the created file to the device you want to Import the Weight Entries.',
      );
    } finally {
      eventChannel.fireEvent(WeightEvent.finishExport.event, null);
    }
  }

  @override
  void initState() {
    super.initState();
    listener = context.eventChannel.eventBus.addEventListener<String>(
      WeightEvent.exportedJson.event,
      (event, value) => finishExport(value),
    );
  }

  @override
  void dispose() {
    super.dispose();
    listener.unsubscribe();
  }

  @override
  Widget build(BuildContext context) {
    final bloc = context.watchBloc<ImportExportBloc>();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Import / Export'),
        leading: BackButton(
          onPressed: () => context.fireEvent(
            WeightEvent.showImportExportScreen.event,
            false,
          ),
        ),
      ),
      body: bloc.state == ImportExportState.idle
          ? ListView(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(10, 10, 10, 0),
                  child: ElevatedButton(
                    onPressed: () =>
                        context.fireEvent(WeightEvent.export.event, null),
                    child: const Text('Export Weight Entries'),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(10, 10, 10, 0),
                  child: ElevatedButton(
                    onPressed: () async {
                      final eventChannel = context.eventChannel;
                      eventChannel.fireEvent(
                          WeightEvent.startImport.event, null);
                      final result = await FilePicker.platform.pickFiles(
                        dialogTitle: 'Import Weight Entry Json',
                        allowedExtensions: ['json'],
                        type: FileType.custom,
                        withData: true,
                      );
                      if (result == null) {
                        eventChannel.fireEvent(
                            WeightEvent.finishImport.event, null);
                        return;
                      }
                      final bytes = result.files.first.bytes;
                      if (bytes == null) {
                        eventChannel.fireEvent(
                            WeightEvent.finishImport.event, null);
                        eventChannel.fireError(
                            'There was an issue reading the weight entry file!');
                        return;
                      }
                      final logs = utf8.decode(bytes);
                      eventChannel.fireEvent(WeightEvent.import.event, logs);
                    },
                    child: const Text('Import Weight Entries'),
                  ),
                ),
              ],
            )
          : const LoadingImportExportScreen(),
    );
  }
}

class LoadingImportExportScreen extends StatelessWidget {
  const LoadingImportExportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final bloc = context.watchBloc<ImportExportBloc>();
    return Column(
      children: [
        const Expanded(
          flex: 3,
          child: SizedBox(
            width: double.infinity,
          ),
        ),
        const SizedBox(
          width: 125,
          height: 125,
          child: CircularProgressIndicator(),
        ),
        const Expanded(
          child: SizedBox(),
        ),
        Text('${bloc.state.action}ing...'),
        const Expanded(
          flex: 3,
          child: SizedBox(),
        ),
      ],
    );
  }
}
