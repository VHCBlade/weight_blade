import 'package:flutter/material.dart';
import 'package:weight_blade/model/weight.dart';

class WeightEntryModal extends StatefulWidget {
  late final WeightEntry entry;

  WeightEntryModal({super.key, WeightEntry? initialEntry}) {
    entry = WeightEntry();
    if (initialEntry != null) {
      entry.copy(initialEntry);
    }
  }

  @override
  State<WeightEntryModal> createState() => _WeightEntryModalState();
}

class _WeightEntryModalState extends State<WeightEntryModal> {
  late final controller = TextEditingController(text: "${widget.entry.weight}");
  late final focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    focusNode.requestFocus();
  }

  void onEditingComplete() {
    try {
      widget.entry.weight = double.parse(controller.text);
    } on FormatException {
      controller.text = "${widget.entry.weight}";
    }
  }

  void onSave() {
    onEditingComplete();
    Navigator.of(context).pop(widget.entry);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
        title: const Text("Set Weight"),
        content: Row(children: [
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
              onPressed: () => setState(() => widget.entry.unit =
                  widget.entry.unit == WeightUnit.lbs
                      ? WeightUnit.kg
                      : WeightUnit.lbs),
              child: Text(widget.entry.unit.name))
        ]),
        actions: [
          OutlinedButton(
              onPressed: () => Navigator.of(context).pop(null),
              child: const Text("Cancel")),
          ElevatedButton(onPressed: onSave, child: const Text("Save")),
        ]);
  }
}
