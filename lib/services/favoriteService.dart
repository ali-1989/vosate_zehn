import 'package:iris_db/iris_db.dart';

import 'package:app/models/subBuketModel.dart';
import 'package:app/system/keys.dart';
import 'package:app/tools/app/appDb.dart';

class FavoriteService {
  FavoriteService._();

  static Future<bool> addFavorite(SubBucketModel model) async {
    final con = Conditions();
    con.add(Condition()..key = Keys.id..value = model.id!);

    final value = {};
    value[Keys.id] = model.id;
    value[Keys.value] = model.toMap();

    final res = await AppDB.db.insertOrUpdate(AppDB.tbFavorites, value, con);

    return res > 0;
  }

  static Future<bool> removeFavorite(int id) async {
    final con = Conditions();
    con.add(Condition()..key = Keys.id..value = id);

    final res = await AppDB.db.delete(AppDB.tbFavorites, con);

    return res > 0;
  }

  static bool isFavorite(int id) {
    final con = Conditions();
    con.add(Condition()..key = Keys.id..value = id);

    return AppDB.db.exist(AppDB.tbFavorites, con);
  }

  static List<SubBucketModel> getAllFavorites() {
    final con = Conditions();
    //con.add(Condition()..key = Keys.id..value = id);

    final rawList = AppDB.db.query(AppDB.tbFavorites, con);

    List<SubBucketModel> res = [];

    for(final i in rawList){
      res.add(SubBucketModel.fromMap(i[Keys.value]));
    }

    return res;
  }
}
