import 'dart:async';

import 'package:event_bloc/event_bloc_widgets.dart';
import 'package:flutter/material.dart';
import 'package:weight_blade/bloc/goal.dart';
import 'package:weight_blade/model/goal.dart';
import 'package:weight_blade/model/weight.dart';

class WeightGoalText extends StatefulWidget {
  final WeightGoal? goal;
  final WeightEntry? entry;

  const WeightGoalText({super.key, this.goal, this.entry});

  @override
  State<WeightGoalText> createState() => _WeightGoalTextState();
}

class _WeightGoalTextState extends State<WeightGoalText> {
  late final StreamSubscription subscription;

  @override
  void initState() {
    super.initState();
    subscription =
        context.readBloc<WeightGoalWatcherBloc>().finishedGoal.listen(
              (event) => showDialog(
                context: context,
                builder: (_) => AlertDialog(
                  title: Text(
                      "You've achieved your goal of ${event.direction.action} ${event.weight} ${event.unit.name}!"),
                  actions: [
                    ElevatedButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text("Hooray!"))
                  ],
                ),
              ),
            );
  }

  @override
  void dispose() {
    subscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bloc = context.watchBloc<WeightGoalWatcherBloc>();
    final goal = bloc.goal;

    if (goal == null) {
      return const Text("Weight Tracker - No Goal");
    }
    final units = "${goal.weight} ${goal.unit.name}";
    final weightToGoal = bloc.weightToGoal;

    final difference = weightToGoal == null
        ? ""
        : "- ${weightToGoal > 0 ? "Gain " : "Lose "}${(weightToGoal.abs() * 10).round() / 10}";
    return Text("Goal: $units $difference");
  }
}
