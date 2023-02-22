import 'package:flutter/material.dart';
import 'package:weight_blade/model/goal.dart';
import 'package:weight_blade/model/weight.dart';

class WeightGoalText extends StatelessWidget {
  final WeightGoal? goal;
  final WeightEntry? entry;

  const WeightGoalText({super.key, this.goal, this.entry});

  @override
  Widget build(BuildContext context) {
    return const Text("Weight Tracker");
  }
}
