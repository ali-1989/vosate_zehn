import 'package:iris_db/iris_db.dart';
import 'package:iris_tools/api/helpers/databaseHelper.dart';
import 'package:vosate_zehn/tools/app/appNotification.dart';

import '/system/keys.dart';

class AppDB {
  AppDB._();

  static late final DatabaseHelper db;
  ///-------- tables -------------------------------------------------------------------------------------
  static String tbKv = 'KvTable';
  static String tbUserModel = 'UserModel';
  static String tbLanguages = 'Languages';


  static Future<bool> firstDatabasePrepare() async {
    //await insertLanguages();
    await AppNotification.insertNotificationIds();

    return true;
  }
  ///------------------------------------------------------------------------------------------
  /// 1 is ok and 0 is fail
  static Future<int> setReplaceKv(String key, dynamic data){
    final con = Conditions();
    con.add(Condition()..key = Keys.name..value = key);

    final cell = <String, dynamic>{};
    cell[Keys.name] = key;
    cell[Keys.value] = data;

    return AppDB.db.insertOrReplace(AppDB.tbKv, cell, con);
  }

  static Future<int> deleteKv(String key){
    final con = Conditions();
    con.add(Condition()..key = Keys.name..value = key);

    return AppDB.db.delete(AppDB.tbKv, con);
  }

  static Future<int> addToList<T>(String key, T data){
    final con = Conditions();
    con.add(Condition()..key = Keys.name..value = key);

    final exist = AppDB.db.queryFirst(AppDB.tbKv, con);

    if(exist != null){
      final newList = (exist[Keys.value] as List).map((e) => e as T).toList();

      if(!newList.contains(data)) {
        newList.add(data);
      }

      final cell = <String, dynamic>{};
      cell[Keys.name] = key;
      cell[Keys.value] = newList;

      return AppDB.db.update(AppDB.tbKv, cell, con);
    }
    else {
      final cell = <String, dynamic>{};
      cell[Keys.name] = key;
      cell[Keys.value] = <T>[data];

      return AppDB.db.insert(AppDB.tbKv, cell);
    }
  }

  static Future<bool> removeFromList<T>(String key, T data) async {
    final con = Conditions();
    con.add(Condition()..key = Keys.name..value = key);

    final exist = AppDB.db.queryFirst(AppDB.tbKv, con);

    if(exist != null){
      final newList = (exist[Keys.value] as List).map((e) => e as T).toList();
      newList.remove(data);

      if(newList.isNotEmpty) {
        final cell = <String, dynamic>{};
        cell[Keys.name] = key;
        cell[Keys.value] = newList;

        return (await AppDB.db.update(AppDB.tbKv, cell, con)) > -1;
      }
      else {
        return (await AppDB.db.delete(AppDB.tbKv, con)) > -1;
      }
    }

    return true;
  }

  static List fetchKvs(String key){
    final con = Conditions();
    con.add(Condition()..key = Keys.name..value = key);

    final res = AppDB.db.query(AppDB.tbKv, con);

    if(res.isEmpty){
      return res;
    }

    return res.map((e) => e[Keys.value]).toList();
  }

  static dynamic fetchKv(String key){
    final con = Conditions();
    con.add(Condition()..key = Keys.name..value = key);

    final res = AppDB.db.query(AppDB.tbKv, con);

    if(res.isEmpty){
      return null;
    }

    return res[0][Keys.value];
  }

  static List<T> fetchAsList<T>(String key){
    final con = Conditions();
    con.add(Condition()..key = Keys.name..value = key);

    final res = AppDB.db.query(AppDB.tbKv, con);

    if(res.isEmpty){
      return [];
    }

    return res[0][Keys.value] as List<T>;
  }
  ///------------------------------------------------------------------------------------------
}
