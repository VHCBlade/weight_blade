import 'package:event_bloc/event_bloc_widgets.dart';
import 'package:flutter/material.dart';
import 'package:weight_blade/event/weight.dart';

class ImportExportScreen extends StatelessWidget {
  const ImportExportScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
    );
  }
}
