import 'package:flutter/foundation.dart';

import 'package:iris_db/iris_db.dart';
import 'package:iris_tools/api/converter.dart';
import 'package:iris_tools/api/helpers/databaseHelper.dart';

import 'package:app/system/constants.dart';
import 'package:app/system/keys.dart';
import 'package:app/tools/app/app_directories.dart';

class AppDB {
  AppDB._();

  static bool _isInit = false;
  static late final DatabaseHelper db;

  static Future<DatabaseHelper> init() async {
    if(_isInit){
      return db;
    }

    AppDB.db = DatabaseHelper();
    AppDB.db.setDebug(false);
    _isInit = true;

    if(kIsWeb){
      AppDB.db.setDatabasePath('${await AppDirectories.getDatabasesDir()}/${Constants.appName}');
    }
    else {
      AppDB.db.setDatabasePath(await AppDirectories.getDatabasesDir());
    }

    await AppDB.db.openTable(AppDB.tbKv);
    await AppDB.db.openTable(AppDB.tbLanguages);
    await AppDB.db.openTable(AppDB.tbUsers);
    await AppDB.db.openTable(AppDB.tbFavorites);
    await AppDB.db.openTable(AppDB.tbLastSeen);
    await AppDB.db.openTable(AppDB.tbMedia);
    await AppDB.db.openTable(AppDB.tbAdvertising);

    return AppDB.db;
  }
  ///-------- tables -------------------------------------------------------------------------------------
  static String tbKv = 'KvTable';
  static String tbUsers = 'UserModel';
  static String tbFavorites = 'Favorites';
  static String tbLastSeen = 'LastSeen';
  static String tbMedia = 'Media';
  static String tbLanguages = 'Languages';
  static String tbAdvertising = 'Advertising';


  static Future<bool> firstLaunch() async {
    //await insertLanguages();

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

  static T? fetchKv<T>(String key){
    final con = Conditions();
    con.add(Condition()..key = Keys.name..value = key);

    final res = AppDB.db.query(AppDB.tbKv, con);

    if(res.isEmpty){
      return null;
    }

    return res[0][Keys.value] as T;
  }

  static List<T> fetchAsList<T>(String key){
    final con = Conditions();
    con.add(Condition()..key = Keys.name..value = key);

    final res = AppDB.db.query(AppDB.tbKv, con);

    if(res.isEmpty){
      return [];
    }

    return Converter.correctList<T>(res[0][Keys.value])!;
  }
  ///------------------------------------------------------------------------------------------
}
