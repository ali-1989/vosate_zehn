// ignore_for_file: empty_catches

import 'dart:core';

import 'package:iris_tools/models/dataModels/mediaModel.dart';

class MediaManager {
  MediaManager._();
  
  static final List<MediaModel> _list = [];
  static List<MediaModel> get materialList => _list;
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

  static Future removeItem(int id/*, bool fromDb*/) async {
    _list.removeWhere((element) => element.id == id);
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
  }
}
