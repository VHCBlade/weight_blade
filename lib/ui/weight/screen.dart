import 'package:event_bloc/event_bloc_widgets.dart';
import 'package:event_modals/event_modals.dart';
import 'package:flutter/material.dart';
import 'package:weight_blade/bloc/goal.dart';
import 'package:weight_blade/bloc/weight_entry.dart';
import 'package:weight_blade/event/goal.dart';
import 'package:weight_blade/event/weight.dart';
import 'package:weight_blade/model/goal.dart';
import 'package:weight_blade/ui/weight/entries/list.dart';
import 'package:weight_blade/ui/weight/goal.dart';
import 'package:weight_blade/ui/weight/modal.dart';

import '../../model/weight.dart';

class WeightScreen extends StatefulWidget {
  const WeightScreen({super.key});

  @override
  State<WeightScreen> createState() => _WeightScreenState();
}

class _WeightScreenState extends State<WeightScreen> {
  @override
  void initState() {
    final weightBloc = context.readBloc<WeightEntryBloc>();
    if (weightBloc.ledger != null) {
      context.fireEvent<String?>(
          GoalEvent.loadWeightGoal.event, weightBloc.ledger!.currentWeightGoal);
    }
    if (weightBloc.loadedEntries.isEmpty) {
      context.fireEvent<int>(WeightEvent.loadNWeightEntries.event, 20);
    }

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final weightBloc = context.watchBloc<WeightEntryBloc>();
    final goalBloc = context.watchBloc<WeightGoalBloc>();

    final goal = goalBloc.weightGoalMap[weightBloc.ledger?.currentWeightGoal];

    return Scaffold(
      appBar: AppBar(
        title: WeightGoalText(goal: goal),
        actions: [
          IconButton(
            onPressed: () async {
              final noCurrentGoal = goal == null;
              await showEventDialog<WeightGoal>(
                context: context,
                builder: (_) => WeightGoalModal(goal: goal),
                onResponse: (eventChannel, response) =>
                    eventChannel.fireEvent<WeightGoal>(
                        noCurrentGoal
                            ? GoalEvent.addWeightGoal.event
                            : GoalEvent.updateWeightGoal.event,
                        response),
              );
            },
            icon: goal == null ? const Icon(Icons.add) : const Icon(Icons.edit),
          )
        ],
      ),
      body: const WeightEntryList(),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add,
            color: Theme.of(context).textTheme.displayMedium?.color),
        onPressed: () => showEventDialog<WeightEntry>(
          context: context,
          onResponse: (BlocEventChannel eventChannel, response) =>
              eventChannel.fireEvent<WeightEntry>(
                  WeightEvent.addWeightEntry.event, response),
          builder: (_) => WeightEntryWithDateModal(
            entry: WeightEntry()
              ..copy(weightBloc.latestEntry ?? WeightEntry())
              ..id = null
              ..dateTime = DateTime.now(),
          ),
        ),
      ),
    );
  }
}
