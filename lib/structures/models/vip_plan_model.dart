
import 'package:app/system/keys.dart';
import 'package:iris_tools/dateSection/dateHelper.dart';

class VipPlanModel {
  int id = 0;
  int amount = 0;
  int days = 0;
  String title = '';
  String? description;
  DateTime? expireDate;

  VipPlanModel();

  VipPlanModel.fromMap(Map map) {
    id = map[Keys.id];
    amount = map['amount'];
    days = map['days'];
    title = map['title'];
    description = map['description'];
    expireDate = DateHelper.timestampToSystem(map['expire_date']);

  }

  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{};

    map[Keys.id] = id;
    map['amount'] = amount;
    map['days'] = days;
    map['title'] = title;
    map['description'] = description;
    map['expire_date'] = DateHelper.toTimestampNullable(expireDate);


    return map;
  }
}
