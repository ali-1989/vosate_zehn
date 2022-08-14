import 'package:iris_db/iris_db.dart';

import 'package:vosate_zehn/models/level2Model.dart';
import 'package:vosate_zehn/system/keys.dart';
import 'package:vosate_zehn/tools/app/appDb.dart';

class FavoriteService {
  FavoriteService._();

  static Future<bool> addFavorite(Level2Model model) async {
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

  static List<Level2Model> getAllFavorites() {
    final con = Conditions();
    //con.add(Condition()..key = Keys.id..value = id);

    final rawList = AppDB.db.query(AppDB.tbFavorites, con);

    List<Level2Model> res = [];

    for(final i in rawList){
      res.add(Level2Model.fromMap(i[Keys.value]));
    }

    return res;
  }
}
