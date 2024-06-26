// ignore_for_file: empty_catches

import 'dart:core';

import 'package:flutter/material.dart';

import 'package:iris_tools/api/helpers/jsonHelper.dart';
import 'package:iris_tools/api/helpers/urlHelper.dart';
import 'package:iris_tools/widgets/iris_image_view.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:app/managers/media_manager.dart';
import 'package:app/services/vip_service.dart';
import 'package:app/structures/enums/enums.dart';
import 'package:app/structures/models/advModel.dart';
import 'package:app/structures/models/subBuketModel.dart';
import 'package:app/tools/app/app_dialog_iris.dart';
import 'package:app/tools/app/app_directories.dart';
import 'package:app/tools/app_tools.dart';
import 'package:app/tools/route_tools.dart';

class CarouselManager {
  CarouselManager._();
  
  static final List<AdvModel> _carouselList = [];
  static List<AdvModel> get carouselList => _carouselList;

  static AdvModel? getById(int? id){
    try {
      return _carouselList.firstWhere((element) => element.id == id);
    }
    catch(e){
      return null;
    }
  }

  static AdvModel addItem(AdvModel item){
    final existItem = getById(item.id);
    item.mediaModel ??= MediaManager.getById(item.mediaId);

    if(existItem == null) {
      _carouselList.add(item);
      return item;
    }
    else {
      existItem.matchBy(item);
      return existItem;
    }
  }

  static List<AdvModel> addItemsFromMap(List? itemList, {String? domain}){
    final res = <AdvModel>[];

    if(itemList != null){
      for(final row in itemList){
        final itm = AdvModel.fromMap(row, /*domain: domain*/);
        addItem(itm);

        res.add(itm);
      }
    }

    return res;
  }

  static Future removeItem(int id/*, bool fromDb*/) async {
    _carouselList.removeWhere((element) => element.id == id);
  }

  static void sortList(bool asc) async {
    _carouselList.sort((AdvModel p1, AdvModel p2){
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
    _carouselList.removeWhere((element) => !serverIds.contains(element.id));
  }

  static List<Widget> getCarousel(){
    final res = <Widget>[];

    for(final cr in _carouselList){
      final v = GestureDetector(
        onTap: (){
          onCarouselClick(cr);
        },
        child: IrisImageView(
          height: 170,
          url: cr.mediaModel!.url,
          fit: BoxFit.fill,
          imagePath: AppDirectories.getSavePathMedia(cr.mediaModel, SavePathType.anyOnInternal, null),
        ),
      );

      res.add(v);
    }

    return res;
  }

  static bool hasAdv1(){
    return _carouselList.indexWhere((element) => element.tag == 'avd1') > -1;
  }

  static void onCarouselClick(AdvModel itm) {
    if(itm.clickUrl == null || itm.clickUrl!.isEmpty){
      return;
    }

    if(itm.type == 'url'){
      if(itm.clickUrl == 'buy_page'){
        VipService.gotoBuyVipPage(null);
        return;
      }

      // https://t.me/VosateZehnApp, https://eitaa.com/VosateZehnApp
      UrlHelper.launchWeb(itm.clickUrl!, mode: LaunchMode.externalApplication);
    }

    else if(itm.type == 'sub_bucket'){
      final t = JsonHelper.jsonToMap(itm.clickUrl);
      final sub = SubBucketModel.fromMap(t!);
      sub.mediaModel = MediaManager.getById(sub.mediaId);
      sub.imageModel = MediaManager.getById(sub.coverId?? sub.mediaId);

      _onCarouselClickSubBucket(sub);
    }

    else if(itm.type == 'text'){
      AppDialogIris.instance.showIrisDialog(RouteTools.getTopContext()!,
          desc: itm.clickUrl!,
        yesText: 'بله'
      );
    }
  }

  static void _onCarouselClickSubBucket(SubBucketModel itm) {
    AppTools.onItemClick(RouteTools.getTopContext()!, itm);
  }
}
