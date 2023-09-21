// ignore_for_file: empty_catches

import 'dart:core';

import 'package:flutter/foundation.dart';

import 'package:iris_db/iris_db.dart';
import 'package:iris_tools/models/dataModels/media_model.dart';

import 'package:app/system/keys.dart';
import 'package:app/tools/app/app_db.dart';

class MediaManager {
  MediaManager._();
  
  static final List<MediaModel> _list = [];
  static List<MediaModel> get mediaList => _list;
  ///-----------------------------------------------------------------------------------------
  static MediaModel? getById(int? id){
    try {
      return _list.firstWhere((element) => element.id == id);
    }
    catch(e){
      return null;
    }
  }

  static MediaModel addItem(MediaModel item){
    final existItem = getById(item.id);

    if(existItem == null) {
      _list.add(item);
      return item;
    }
    else {
      existItem.matchBy(item);
      return existItem;
    }
  }

  static List<MediaModel> addItemsFromMap(List? itemList, {String? domain}){
    final res = <MediaModel>[];

    if(itemList != null){
      for(final row in itemList){
        final itm = MediaModel.fromMap(row, /*domain: domain*/);
        addItem(itm);

        res.add(itm);
      }
    }

    return res;
  }

  static Future removeItem(int id, bool fromDb) async {
    _list.removeWhere((element) => element.id == id);

    if(fromDb){
      final con = Conditions();
      con.add(Condition()..key = Keys.id..value = id);
      AppDB.db.delete(AppDB.tbMedia, con);
    }
  }

  static void sortList(bool asc) async {
    _list.sort((MediaModel p1, MediaModel p2){
      final d1 = p1.date;
      final d2 = p2.date;

      if(d1 == null){
        return asc? 1: 1;
      }

      if(d2 == null){
        return asc? 1: 1;
      }

      return asc? d1.compareTo(d2) : d2.compareTo(d1);
    });
  }

  static Future removeNotMatchByServer(List<int> serverIds) async {
    _list.removeWhere((element) => !serverIds.contains(element.id));

    Conditions con = Conditions();
    con.add(Condition(ConditionType.NotIn)..key = Keys.id..value = serverIds);

    return AppDB.db.delete(AppDB.tbMedia, con);
  }

  static Future sinkItems(List<MediaModel> list) async {
    final con = Conditions();

    for(final row in list) {
      con.clearConditions();
      con.add(Condition()..key = Keys.id..value = row.id);

      await AppDB.db.insertOrUpdate(AppDB.tbMedia, row.toMap(), con);
    }
  }

  static Future<void> loadAllRecords(){
    final con = Conditions();
    final list = AppDB.db.query(AppDB.tbMedia, con);

    addItemsFromMap(list);

    return SynchronousFuture(null);
  }

  static Future<void> loadByIds(List<int> ids) async {
    final con = Conditions()
      ..add(Condition(ConditionType.IN)..key = Keys.id..value = ids);

    final cursor = AppDB.db.query(AppDB.tbMedia, con);

    if(cursor.isEmpty){
      return SynchronousFuture(null);
    }

    final fetchList = cursor.map((e) => e as Map<String, dynamic>).toList();

    for(var row in fetchList){
      final itm = MediaModel.fromMap(row);

      addItem(itm);
    }

    return SynchronousFuture(null);
  }
}
