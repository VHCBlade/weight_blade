import 'package:event_ads/event_ads.dart';
import 'package:event_bloc/event_bloc.dart';
import 'package:event_db/event_db.dart';
import 'package:tuple/tuple.dart';
import 'package:weight_blade/bloc/weight_entry.dart';
import 'package:weight_blade/event/ledger.dart';
import 'package:weight_blade/event/weight.dart';
import 'package:weight_blade/model/settings.dart';
import 'package:weight_blade/model/weight.dart';

const adModelKey = "adModelKey";

class AdModel extends GenericModel {
  int weightCount = 0;

  @override
  Map<String, Tuple2<Getter, Setter>> getGetterSetterMap() => {
        "weightCount":
            Tuple2(() => weightCount, (val) => weightCount = val ?? 0)
      };

  @override
  String get type => "WBAdModel";
}

class AdBloc extends Bloc {
  final DatabaseRepository repository;
  final WBSettings Function() settingsGetter;
  AdModel adModel = AdModel()..id = adModelKey;

  AdBloc(
      {required super.parentChannel,
      required this.repository,
      required this.settingsGetter}) {
    eventChannel.addEventListener<void>(
        LedgerEvent.loadLedger.event,
        (p0, p1) async => adModel = await repository.findModel<AdModel>(
                weightDb, adModelKey) ??
            AdModel()
          ..id = adModelKey);
    eventChannel.addEventListener<WeightEntry>(WeightEvent.addWeightEntry.event,
        (p0, p1) {
      final settings = settingsGetter();
      if (!settings.enableAdsAppWide) {
        return;
      }
      adModel.weightCount = adModel.weightCount + 1;
      print(adModel.weightCount);

      if (adModel.weightCount % settings.showAdEveryNEntries == 0) {
        // eventChannel.fireEvent(AdEvent.showAd.event, null);
        eventChannel.fireEvent(AdEvent.showRewardedAdWithCallback.event,
            (reward) => print(reward));
      }
      repository.saveModel(weightDb, adModel);
    });
  }
}
