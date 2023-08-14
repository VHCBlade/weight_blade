import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:weight_blade/bloc/settings/extension.dart';
import 'package:weight_blade/model/goal.dart';
import 'package:weight_blade/model/weight.dart';

const weightEntryCancelKey = ValueKey("WeightEntryModal Cancel");
const weightEntrySaveKey = ValueKey("WeightEntryModal Save");
const weightEntryWeightTextKey = ValueKey("WeightEntryModal WeightText");
const weightEntryUnitKey = ValueKey("WeightEntryModal Unit");
const weightEntryNoteKey = ValueKey("WeightEntryModal Note");
const weightEntryNoteTextKey = ValueKey("WeightEntryModal NoteText");

class WeightEntryModal extends StatefulWidget {
  final WeightEntry? entry;
  final void Function(WeightEntry)? onSave;
  final Widget? extraContent;
  final Widget? title;
  final bool editWeight;

  const WeightEntryModal({
    super.key,
    this.entry,
    this.onSave,
    this.extraContent,
    this.title,
    this.editWeight = false,
  });

  @override
  State<WeightEntryModal> createState() => _WeightEntryModalState();
}

class _WeightEntryModalState extends State<WeightEntryModal> {
  late final controller = TextEditingController(text: "${currentEntry.weight}");
  late final focusNode = FocusNode();
  late final currentEntry = WeightEntry();

  @override
  void initState() {
    super.initState();
    focusNode.requestFocus();
    if (widget.entry != null) {
      currentEntry
          .copy(widget.entry!, exceptFields: [if (!widget.editWeight) "note"]);
    }
  }

  void onEditingComplete() {
    try {
      currentEntry.weight = double.parse(controller.text);
    } on FormatException {
      controller.text = "${currentEntry.weight}";
    }
  }

  void onSave() {
    onEditingComplete();
    if (widget.onSave != null) {
      widget.onSave!(currentEntry);
      return;
    }
    Navigator.of(context).pop(currentEntry);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
        title: widget.title ??
            (widget.editWeight
                ? const Text('Edit Weight')
                : const Text('Add Weight')),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          Row(children: [
            Expanded(
              child: TextField(
                key: weightEntryWeightTextKey,
                controller: controller,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                focusNode: focusNode,
                onEditingComplete: onEditingComplete,
                onSubmitted: (_) => onSave(),
              ),
            ),
            const SizedBox(width: 10),
            ElevatedButton(
                key: weightEntryUnitKey,
                onPressed: () {
                  final unit = currentEntry.unit == WeightUnit.lbs
                      ? WeightUnit.kg
                      : WeightUnit.lbs;
                  final currentWeight = double.tryParse(controller.text);

                  if (currentWeight != null &&
                      context.readSettings.automaticallyConvertUnits) {
                    final weight = unit.convertFromLbs(
                        currentEntry.unit.convertToLbs(currentWeight));
                    final roundedWeight = (weight * 10).round() / 10;

                    controller.text = "$roundedWeight";
                  }
                  currentEntry.unit = unit;
                  setState(() {});
                },
                child: Text(currentEntry.unit.name))
          ]),
          widget.extraContent ?? Container(),
        ]),
        actions: [
          OutlinedButton(
            key: weightEntryCancelKey,
            onPressed: () => Navigator.of(context).pop(null),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            key: weightEntrySaveKey,
            onPressed: onSave,
            child: const Text("Save"),
          ),
        ]);
  }
}

class WeightGoalModal extends StatefulWidget {
  final WeightGoal? goal;
  const WeightGoalModal({super.key, this.goal});

  @override
  State<WeightGoalModal> createState() => _WeightGoalModalState();
}

class _WeightGoalModalState extends State<WeightGoalModal> {
  late final WeightEntry? entry;
  late final WeightGoal goal;

  @override
  void initState() {
    if (widget.goal == null) {
      entry = null;
    } else {
      entry = WeightEntry();
      entry!.unit = widget.goal!.unit;
      entry!.weight = widget.goal!.weight;
    }
    goal = widget.goal ?? WeightGoal();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return WeightEntryModal(
      entry: entry,
      extraContent: Padding(
        padding: const EdgeInsets.only(top: 13),
        child: Row(
          children: [
            const Text("I want to "),
            ElevatedButton(
                onPressed: () {
                  goal.direction = goal.direction == TargetDirection.gain
                      ? TargetDirection.lose
                      : TargetDirection.gain;
                  setState(() {});
                },
                child: Text(goal.direction.name)),
            const Text(" weight."),
          ],
        ),
      ),
      onSave: (entry) {
        goal.unit = entry.unit;
        goal.weight = entry.weight;
        return Navigator.of(context).pop(goal);
      },
      title: const Text("Set Goal"),
    );
  }
}

class WeightEntryWithDateModal extends StatefulWidget {
  final WeightEntry? entry;
  final bool editWeight;
  const WeightEntryWithDateModal({
    super.key,
    this.entry,
    this.editWeight = false,
  });

  @override
  State<WeightEntryWithDateModal> createState() => _WeightEntryWithDateModal();
}

class _WeightEntryWithDateModal extends State<WeightEntryWithDateModal> {
  late DateTime dateTime;

  @override
  void initState() {
    dateTime = widget.entry?.dateTime ?? DateTime.now();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return WeightEntryModal(
      entry: widget.entry,
      editWeight: widget.editWeight,
      extraContent: Padding(
        padding: const EdgeInsets.only(top: 13),
        child: Row(
          children: [
            const Text("Date"),
            const Expanded(child: SizedBox()),
            ElevatedButton(
                onPressed: () async {
                  final newDateTime = await showDatePicker(
                      context: context,
                      initialDate: dateTime,
                      firstDate: DateTime(1970),
                      lastDate: DateTime.now());

                  dateTime = newDateTime ?? dateTime;
                  setState(() {});
                },
                child: Text(DateFormat.yMMMMd().format(dateTime))),
          ],
        ),
      ),
      onSave: (entry) {
        entry.dateTime = dateTime;
        Navigator.of(context).pop(entry);
      },
    );
  }
}
