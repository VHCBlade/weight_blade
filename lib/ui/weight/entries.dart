import 'package:event_bloc/event_bloc_widgets.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:weight_blade/bloc/weight_entry.dart';
import 'package:weight_blade/event/weight.dart';
import 'package:weight_blade/model/weight.dart';
import 'package:weight_blade/ui/weight/modal.dart';

final dateFormatter = DateFormat("MMM dd, yyyy").add_jm();

class WeightEntryList extends StatefulWidget {
  const WeightEntryList({super.key});

  @override
  State<WeightEntryList> createState() => _WeightEntryListState();
}

class _WeightEntryListState extends State<WeightEntryList> {
  late final controller = ScrollController();
  bool sentUpdateRequest = false;

  @override
  void initState() {
    super.initState();
    controller.addListener(listener);
  }

  void listener() async {
    if (sentUpdateRequest || controller.position.extentAfter > 80) {
      return;
    }

    sentUpdateRequest = true;
    context.fireEvent(WeightEvent.loadNWeightEntries.event, 50);

    await Future.delayed(const Duration(seconds: 3));
    sentUpdateRequest = false;
  }

  @override
  void dispose() {
    super.dispose();
    controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final weightBloc = context.watchBloc<WeightEntryBloc>();

    if (weightBloc.loadedEntries.isEmpty) {
      return weightBloc.noEntries
          ? Center(
              child: Text(
              "No Weight Entries Yet. Add one!",
              style: Theme.of(context).textTheme.headlineMedium,
              textAlign: TextAlign.center,
            ))
          : Container();
    }

    return ListView.builder(
        itemBuilder: (_, i) => i == weightBloc.loadedEntries.length
            ? const SizedBox(height: 80)
            : WeightEntryWidget(entry: weightBloc.entryAt(i)!),
        physics: const AlwaysScrollableScrollPhysics(),
        controller: controller,
        itemCount: weightBloc.loadedEntries.length + 1);
  }
}

class WeightEntryWidget extends StatelessWidget {
  final WeightEntry entry;
  const WeightEntryWidget({super.key, required this.entry});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(5, 5, 5, 0),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          child: Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("${entry.weight} ${entry.unit.name}"),
                  Text(dateFormatter.format(entry.dateTime),
                      style: Theme.of(context).textTheme.labelSmall),
                ],
              ),
              Expanded(child: Container()),
              IconButton(
                  onPressed: () => context.fireEvent(
                      WeightEvent.deleteWeightEntry.event, entry),
                  icon: const Icon(Icons.delete)),
              ElevatedButton(
                  onPressed: () async {
                    final eventChannel = context.eventChannel;
                    final updatedEntry = await showDialog(
                        context: context,
                        builder: (_) => WeightEntryModal(entry: entry));

                    if (updatedEntry == null) {
                      return;
                    }

                    eventChannel.fireEvent<WeightEntry>(
                        WeightEvent.updateWeightEntry.event, updatedEntry);
                  },
                  child: const Text("Edit")),
            ],
          ),
        ),
      ),
    );
  }
}
