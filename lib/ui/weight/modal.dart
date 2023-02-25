import 'package:flutter/material.dart';
import 'package:weight_blade/model/weight.dart';

class WeightEntryModal extends StatefulWidget {
  final WeightEntry? entry;
  final void Function(WeightEntry)? onSave;
  final Widget? extraContent;

  const WeightEntryModal(
      {super.key, this.entry, this.onSave, this.extraContent});

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
      currentEntry.copy(widget.entry!);
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
        title: const Text("Set Weight"),
        content: Column(children: [
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
                  currentEntry.unit = currentEntry.unit == WeightUnit.lbs
                      ? WeightUnit.kg
                      : WeightUnit.lbs;
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
