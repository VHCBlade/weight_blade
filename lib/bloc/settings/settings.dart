import 'package:event_bloc/event_bloc.dart';
import 'package:event_db/event_db.dart';
import 'package:flutter/foundation.dart';
import 'package:weight_blade/bloc/weight_entry.dart';
import 'package:weight_blade/event/settings.dart';
import 'package:weight_blade/model/settings.dart';

const showAdsAtAll = kIsWeb ? false : true;
const settingsKey = "WBSettings";

class SettingsBloc extends Bloc {
  final DatabaseRepository databaseRepository;

  WBSettings get settings => WBSettingsAdDecorator(internalSettingsModel);
  WBSettingsModel internalSettingsModel = WBSettingsModel()..id = settingsKey;

  SettingsBloc(
      {required super.parentChannel, required this.databaseRepository}) {
    eventChannel.addEventListener<void>(
        SettingsEvent.loadSettings.event, (p0, p1) => loadSettings());
    eventChannel.addEventListener<WBSettings>(
        SettingsEvent.saveSettings.event, (p0, p1) => saveSettings(p1));
  }

  void loadSettings() async {
    final loadedSettings = await databaseRepository.findModel<WBSettingsModel>(
        weightDb, settingsKey);

    if (loadedSettings == null) {
      return;
    }

    internalSettingsModel = loadedSettings;
    updateBloc();
  }

  void saveSettings(WBSettings settings) async {
    internalSettingsModel.copySettings(settings.unwrap);
    updateBloc();
    databaseRepository.saveModel<WBSettingsModel>(
        weightDb, internalSettingsModel);
  }
}

class WBSettingsAdDecorator with WBSettings {
  final WBSettings settings;

  @override
  WBSettings get unwrap => settings.unwrap;

  @override
  bool get enableAdsAppWide => settings.enableAdsAppWide && showAdsAtAll;

  @override
  int get showAdEveryNEntries => settings.showAdEveryNEntries;

  @override
  bool get showDeleteConfirmation => settings.showDeleteConfirmation;

  @override
  bool get automaticallyConvertUnits => settings.automaticallyConvertUnits;

  WBSettingsAdDecorator(this.settings);

  @override
  set enableAdsAppWide(bool enableAdsAppWide) =>
      settings.enableAdsAppWide = enableAdsAppWide;

  @override
  set showAdEveryNEntries(int showAdEveryNEntries) =>
      settings.showAdEveryNEntries = showAdEveryNEntries;
  @override
  set showDeleteConfirmation(bool showDeleteConfirmation) =>
      settings.showDeleteConfirmation = showDeleteConfirmation;
  @override
  set automaticallyConvertUnits(bool automaticallyConvertUnits) =>
      settings.automaticallyConvertUnits = automaticallyConvertUnits;
}
