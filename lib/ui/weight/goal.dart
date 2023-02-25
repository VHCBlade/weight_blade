import 'package:event_bloc/event_bloc_widgets.dart';
import 'package:flutter/material.dart';
import 'package:weight_blade/bloc/goal.dart';
import 'package:weight_blade/model/goal.dart';
import 'package:weight_blade/model/weight.dart';

class WeightGoalText extends StatelessWidget {
  final WeightGoal? goal;
  final WeightEntry? entry;

  const WeightGoalText({super.key, this.goal, this.entry});

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
