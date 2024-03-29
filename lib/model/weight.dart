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

  String _note = "";

  String get note => _note;

  set note(String? value) {
    _note = (value ?? "").trimRight();
  }

  @override
  Map<String, Tuple2<Getter, Setter>> getGetterSetterMap() => {
        "unit": GenericModel.convertEnumToString(() => unit,
            (value) => unit = value ?? WeightUnit.lbs, WeightUnit.values),
        "weight": Tuple2(() => weight, (val) => weight = val),
        "time": GenericModel.dateTime(
            () => dateTime, (value) => dateTime = value ?? DateTime.now()),
        "note": Tuple2(() => note, (val) => note = val),
      };

  @override
  String get type => "WeightEntry";
}
