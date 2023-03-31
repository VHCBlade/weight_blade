import 'package:event_hive/event_hive.dart';
import 'package:vhcblade_theme/vhcblade_picker.dart';
import 'package:weight_blade/bloc/ad.dart';
import 'package:weight_blade/model/goal.dart';
import 'package:weight_blade/model/ledger.dart';
import 'package:weight_blade/model/reminder.dart';
import 'package:weight_blade/model/settings.dart';
import 'package:weight_blade/model/weight.dart';

final typeAdapters = <GenericTypeAdapter>[
  GenericTypeAdapter<WeightEntry>(WeightEntry.new, (_) => 1),
  GenericTypeAdapter<Ledger>(Ledger.new, (_) => 2),
  GenericTypeAdapter<WeightGoal>(WeightGoal.new, (_) => 3),
  GenericTypeAdapter<Reminder>(Reminder.new, (_) => 4),
  GenericTypeAdapter<SelectedTheme>(SelectedTheme.new, (_) => 5),
  GenericTypeAdapter<WBSettingsModel>(WBSettingsModel.new, (_) => 6),
  GenericTypeAdapter<AdModel>(AdModel.new, (_) => 7),
  GenericTypeAdapter<UnlockedThemes>(UnlockedThemes.new, (_) => 8),
];
