import 'package:event_hive/event_hive.dart';
import 'package:weight_blade/model/goal.dart';
import 'package:weight_blade/model/ledger.dart';
import 'package:weight_blade/model/weight.dart';

final typeAdapters = <GenericTypeAdapter>[
  GenericTypeAdapter<WeightEntry>(() => WeightEntry(), (_) => 1),
  GenericTypeAdapter<Ledger>(() => Ledger(), (_) => 2),
  GenericTypeAdapter<WeightGoal>(() => WeightGoal(), (_) => 3),
];
