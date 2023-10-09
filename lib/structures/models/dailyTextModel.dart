import 'package:iris_tools/dateSection/dateHelper.dart';

import 'package:app/structures/mixins/date_field_mixin.dart';
import 'package:app/system/keys.dart';

class DailyTextModel with DateFieldMixin {
  int? id;
  late String text;

  DailyTextModel();

  DailyTextModel.fromMap(Map? map){
    if(map == null) {
      return;
    }

    id = map[Keys.id];
    text = map['text'];
    date = DateHelper.timestampToSystem(map[Keys.date]);
  }

  Map<String, dynamic> toMap(){
    final map = <String, dynamic>{};
    map[Keys.id] = id;
    map['text'] = text;

    if(date != null){
      map[Keys.date] = DateHelper.toTimestampNullable(date);
    }

    return map;
  }
}
