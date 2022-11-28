import 'package:iris_db/iris_db.dart';
import 'package:iris_tools/api/helpers/databaseHelper.dart';
import 'package:iris_tools/dateSection/dateHelper.dart';

import 'package:app/managers/mediaManager.dart';
import 'package:app/structures/models/subBuketModel.dart';
import 'package:app/system/keys.dart';
import 'package:app/tools/app/appDb.dart';

class LastSeenService {
  LastSeenService._();

  static Future<bool> addItem(SubBucketModel model, {DateTime? date}) async {
    date ??= DateHelper.getNowToUtc();

    final con = Conditions();
    con.add(Condition()..key = Keys.id..value = model.id!);

    final val = model.toMap();
    val[Keys.sortOrder] = DateHelper.toTimestamp(date);

    final value = {};
    value[Keys.id] = model.id;
    value[Keys.value] = val;

    final res = await AppDB.db.insertOrUpdate(AppDB.tbLastSeen, value, con);
    removeExtraItems();

    return res > 0;
  }

  static Future<bool> removeItem(int id) async {
    final con = Conditions();
    con.add(Condition()..key = Keys.id..value = id);

    final res = await AppDB.db.delete(AppDB.tbLastSeen, con);

    return res > 0;
  }

  static Future removeExtraItems() async {
    final all = getAllItems();

    if(all.length < 21){
      return;
    }

    final ids = [];

    for (int i=0; i < all.length - 20; i++){
      ids.add(all[i+20]);
    }

    for(final k in ids){
      removeItem(k);
    }
  }

  static bool exist(int id) {
    final con = Conditions();
    con.add(Condition()..key = Keys.id..value = id);

    return AppDB.db.exist(AppDB.tbLastSeen, con);
  }

  static List<SubBucketModel> getAllItems() {
    int sort(JSON x1, JSON x2){
      final d1 = x1.mapValue[Keys.value]!.mapValue[Keys.sortOrder]!.stringValue;
      final d2 = x2.mapValue[Keys.value]!.mapValue[Keys.sortOrder]!.stringValue;

      return DateHelper.compareDatesTs(d1, d2, asc: false);
    }

    final con = Conditions();
    final rawList = AppDB.db.query(AppDB.tbLastSeen, con, orderBy: sort);

    List<SubBucketModel> res = [];

    for(final i in rawList){
      final itm = SubBucketModel.fromMap(i[Keys.value]);
      itm.imageModel = MediaManager.getById(itm.coverId);
      itm.mediaModel = MediaManager.getById(itm.mediaId);

      res.add(itm);
    }

    return res;
  }
}
