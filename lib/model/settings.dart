import 'package:event_db/event_db.dart';
import 'package:tuple/tuple.dart';

abstract class WBSettings {
  bool get showDeleteConfirmation;
  bool get enableAdsAppWide;
  int get showAdEveryNEntries;
  WBSettings get unwrap => this;

  set showDeleteConfirmation(bool showDeleteConfirmation);
  set enableAdsAppWide(bool enableAdsAppWide);
  set showAdEveryNEntries(int showAdEveryNEntries);

  void copySettings(WBSettings settings) {
    showDeleteConfirmation = settings.showDeleteConfirmation;
    enableAdsAppWide = settings.enableAdsAppWide;
    showAdEveryNEntries = settings.showAdEveryNEntries;
  }
}

class WBSettingsModel extends GenericModel with WBSettings {
  @override
  bool enableAdsAppWide = true;

  @override
  int showAdEveryNEntries = 20;

  @override
  bool showDeleteConfirmation = true;
  @override
  Map<String, Tuple2<Getter, Setter>> getGetterSetterMap() => {
        "enableAds":
            Tuple2(() => enableAdsAppWide, (val) => enableAdsAppWide = val),
        "entriesBeforeAd": Tuple2(
            () => showAdEveryNEntries, (val) => showAdEveryNEntries = val),
        "deleteConfirmation": Tuple2(() => showDeleteConfirmation,
            (val) => showDeleteConfirmation = val),
      };

  @override
  String get type => "WBSettings";
}
