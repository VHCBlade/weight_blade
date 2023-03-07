import 'package:event_hive/event_hive.dart';
import 'package:vhcblade_theme/vhcblade_picker.dart';
import 'package:weight_blade/bloc/ad.dart';
import 'package:weight_blade/model/goal.dart';
import 'package:weight_blade/model/ledger.dart';
import 'package:weight_blade/model/reminder.dart';
import 'package:weight_blade/model/settings.dart';
import 'package:weight_blade/model/weight.dart';

final typeAdapters = <GenericTypeAdapter>[
  GenericTypeAdapter<WeightEntry>(() => WeightEntry(), (_) => 1),
  GenericTypeAdapter<Ledger>(() => Ledger(), (_) => 2),
  GenericTypeAdapter<WeightGoal>(() => WeightGoal(), (_) => 3),
  GenericTypeAdapter<Reminder>(() => Reminder(), (_) => 4),
  GenericTypeAdapter<SelectedTheme>(() => SelectedTheme(), (_) => 5),
  GenericTypeAdapter<WBSettingsModel>(() => WBSettingsModel(), (_) => 6),
  GenericTypeAdapter<AdModel>(() => AdModel(), (_) => 7),
];
