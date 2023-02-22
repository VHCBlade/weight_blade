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
