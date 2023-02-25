import 'package:event_db/event_db.dart';
import 'package:tuple/tuple.dart';
import 'package:weight_blade/model/weight.dart';

enum TargetDirection {
  lose,
  gain,
  ;
}

class WeightGoal extends GenericModel {
  WeightUnit unit = WeightUnit.lbs;
  TargetDirection direction = TargetDirection.lose;

  double weight = 0;
  DateTime? dateAccomplished;

  bool get accomplished => dateAccomplished != null;
  double get weightInPounds => unit.convertToLbs(weight);

  bool isAccomplishedBy(WeightEntry entry) {
    final diff = difference(entry);
    switch (direction) {
      case TargetDirection.gain:
        return diff <= 0;
      case TargetDirection.lose:
        return diff >= 0;
    }
  }

  /// Givien in this [WeightGoal]'s [unit]
  double difference(WeightEntry entry) {
    final entryWeight = entry.weightInUnits(unit);
    return weight - entryWeight;
  }

  @override
  Map<String, Tuple2<Getter, Setter>> getGetterSetterMap() => {
        "unit": GenericModel.convertEnumToString(() => unit,
            (value) => unit = value ?? WeightUnit.lbs, WeightUnit.values),
        "direction": GenericModel.convertEnumToString(
            () => direction,
            (value) => direction = value ?? TargetDirection.lose,
            TargetDirection.values),
        "weight": Tuple2(() => weight, (val) => weight = val),
        "accomplished": Tuple2(
            () => dateAccomplished?.microsecondsSinceEpoch,
            (val) =>
                dateAccomplished = DateTime.fromMicrosecondsSinceEpoch(val!)),
      };

  @override
  String get type => "WeightGoal";
}
