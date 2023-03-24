import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class MonthPicker extends StatelessWidget {
  final DateTime initialDateTime;
  final void Function(DateTime dateTime) onDateTimeChanged;
  const MonthPicker(
      {super.key,
      required this.initialDateTime,
      required this.onDateTimeChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 250,
      color: Theme.of(context).scaffoldBackgroundColor,
      child: Stack(
        children: [
          CupertinoDatePicker(
            mode: CupertinoDatePickerMode.date,
            initialDateTime: initialDateTime,
            minimumYear: 1900,
            maximumYear: DateTime.now().year,
            onDateTimeChanged: onDateTimeChanged,
          ),
          Positioned(
            bottom: 5,
            right: 5,
            child: ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text("Done")),
          ),
        ],
      ),
    );
  }
}
