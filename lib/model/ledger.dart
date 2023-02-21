import 'package:event_db/event_db.dart';
import 'package:tuple/tuple.dart';

class Ledger extends GenericModel {
  List<String> entries = [];

  @override
  Map<String, Tuple2<Getter, Setter>> getGetterSetterMap() => {
        "entry": Tuple2(
            () => entries, (val) => entries = val.map<String>((a) => "$a"))
      };

  @override
  String get type => "Ledger";
}
