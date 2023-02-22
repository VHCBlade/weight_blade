import 'package:event_db/event_db.dart';
import 'package:tuple/tuple.dart';

class Ledger extends GenericModel {
  List<String> entries = [];
  String? currentWeightGoal;

  @override
  Map<String, Tuple2<Getter, Setter>> getGetterSetterMap() => {
        "entries": Tuple2(() => entries,
            (val) => entries = val.map<String>((a) => "$a").toList()),
        "weightGoal":
            Tuple2(() => currentWeightGoal, (val) => currentWeightGoal = val),
      };

  @override
  String get type => "Ledger";
}
