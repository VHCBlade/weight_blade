import 'package:event_db/event_db.dart';
import 'package:tuple/tuple.dart';

enum WeightUnit {
  kg,
  lbs,
  ;

  convertToLbs(double value) {
    switch (this) {
      case lbs:
        return value;
      case kg:
        return value * 2.204623;
    }
  }

  convertFromLbs(double value) {
    switch (this) {
      case lbs:
        return value;
      case kg:
        return value / 2.204623;
    }
  }
}

class WeightEntry extends GenericModel {
  WeightUnit unit = WeightUnit.lbs;
  double weight = 0;
  DateTime dateTime = DateTime.now();

  double get weightInPounds => unit.convertToLbs(weight);

  double weightInUnits(WeightUnit unit) => unit.convertFromLbs(weightInPounds);

  @override
  Map<String, Tuple2<Getter, Setter>> getGetterSetterMap() => {
        "unit": GenericModel.convertEnumToString(() => unit,
            (value) => unit = value ?? WeightUnit.lbs, WeightUnit.values),
        "weight": Tuple2(() => weight, (val) => weight = val),
        "time": Tuple2(() => dateTime.microsecondsSinceEpoch,
            (val) => dateTime = DateTime.fromMicrosecondsSinceEpoch(val!)),
      };

  @override
  String get type => "WeightEntry";
}
