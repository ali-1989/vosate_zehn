import 'package:iris_db/iris_db.dart';
import 'package:iris_tools/api/helpers/databaseHelper.dart';
import 'package:iris_tools/dateSection/dateHelper.dart';

import 'package:app/managers/mediaManager.dart';
import 'package:app/structures/models/subBuketModel.dart';
import 'package:app/system/keys.dart';
import 'package:app/tools/app/appBroadcast.dart';
import 'package:app/tools/app/appDb.dart';

class FavoriteService {
  FavoriteService._();

  static Future<bool> addFavorite(SubBucketModel model, {DateTime? date}) async {
    date ??= DateHelper.getNowToUtc();

    final con = Conditions();
    con.add(Condition()..key = Keys.id..value = model.id!);

    final val = model.toMap();
    val[Keys.sortOrder] = DateHelper.toTimestamp(date);

    final value = {};
    value[Keys.id] = model.id;
    value[Keys.value] = val;

    final res = await AppDB.db.insertOrUpdate(AppDB.tbFavorites, value, con);
    model.isFavorite = true;
    AppBroadcast.changeFavoriteNotifier.value++;

    return res > 0;
  }

  static Future<bool> removeFavorite(int id) async {
    final con = Conditions();
    con.add(Condition()..key = Keys.id..value = id);

    final res = await AppDB.db.delete(AppDB.tbFavorites, con);
    AppBroadcast.changeFavoriteNotifier.value++;

    return res > 0;
  }

  static bool isFavorite(int id) {
    final con = Conditions();
    con.add(Condition()..key = Keys.id..value = id);

    return AppDB.db.exist(AppDB.tbFavorites, con);
  }

  static List<SubBucketModel> getAllFavorites() {
    int sort(JSON x1, JSON x2){
      final d1 = x1.mapValue[Keys.value]!.mapValue[Keys.sortOrder]!.stringValue;
      final d2 = x2.mapValue[Keys.value]!.mapValue[Keys.sortOrder]!.stringValue;

      return DateHelper.compareDatesTs(d1, d2, asc: false);
    }

    final con = Conditions();
    //con.add(Condition()..key = Keys.id..value = id);

    final rawList = AppDB.db.query(AppDB.tbFavorites, con, orderBy: sort);

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
