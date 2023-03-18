import 'package:event_db/event_db.dart';
import 'package:tuple/tuple.dart';

abstract class WBSettings {
  bool get showDeleteConfirmation;
  bool get enableAdsAppWide;
  int get showAdEveryNEntries;
  bool get automaticallyConvertUnits;

  WBSettings get unwrap => this;

  set showDeleteConfirmation(bool showDeleteConfirmation);
  set enableAdsAppWide(bool enableAdsAppWide);
  set showAdEveryNEntries(int showAdEveryNEntries);
  set automaticallyConvertUnits(bool automaticallyConvertUnits);

  void copySettings(WBSettings settings) {
    showDeleteConfirmation = settings.showDeleteConfirmation;
    enableAdsAppWide = settings.enableAdsAppWide;
    showAdEveryNEntries = settings.showAdEveryNEntries;
    automaticallyConvertUnits = settings.automaticallyConvertUnits;
  }
}

class WBSettingsModel extends GenericModel with WBSettings {
  @override
  bool enableAdsAppWide = true;

  @override
  int showAdEveryNEntries = 10;

  @override
  bool showDeleteConfirmation = true;

  @override
  bool automaticallyConvertUnits = true;
  @override
  Map<String, Tuple2<Getter, Setter>> getGetterSetterMap() => {
        "enableAds":
            Tuple2(() => enableAdsAppWide, (val) => enableAdsAppWide = val),
        "entriesBeforeAd": Tuple2(
            () => showAdEveryNEntries, (val) => showAdEveryNEntries = val),
        "deleteConfirmation": Tuple2(() => showDeleteConfirmation,
            (val) => showDeleteConfirmation = val),
        "automaticallyConvertUnits": Tuple2(() => automaticallyConvertUnits,
            (val) => automaticallyConvertUnits = val ?? true),
      };

  @override
  String get type => "WBSettings";
}
