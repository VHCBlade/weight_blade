import 'package:flutter/material.dart';
import 'package:weight_blade/bloc/settings/extension.dart';
import 'package:weight_blade/model/goal.dart';
import 'package:weight_blade/model/weight.dart';

class WeightEntryModal extends StatefulWidget {
  final WeightEntry? entry;
  final void Function(WeightEntry)? onSave;
  final Widget? extraContent;
  final Widget? title;

  const WeightEntryModal(
      {super.key, this.entry, this.onSave, this.extraContent, this.title});

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
      currentEntry.copy(widget.entry!, exceptFields: ["note"]);
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
        title: widget.title ?? const Text("Set Weight"),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          Row(children: [
            Expanded(
              child: TextField(
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
              onPressed: () => Navigator.of(context).pop(null),
              child: const Text("Cancel")),
          ElevatedButton(onPressed: onSave, child: const Text("Save")),
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
