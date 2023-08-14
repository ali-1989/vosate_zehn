// ignore_for_file: empty_catches

import 'dart:async';
import 'dart:core';

import 'package:iris_db/iris_db.dart';
import 'package:iris_notifier/iris_notifier.dart';
import 'package:iris_tools/api/helpers/jsonHelper.dart';
import 'package:iris_tools/api/helpers/urlHelper.dart';
import 'package:iris_tools/dateSection/dateHelper.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:app/managers/carouselManager.dart';
import 'package:app/managers/mediaManager.dart';
import 'package:app/services/lastSeenService.dart';
import 'package:app/structures/enums/appEvents.dart';
import 'package:app/structures/enums/enums.dart';
import 'package:app/structures/middleWares/requester.dart';
import 'package:app/structures/models/advModel.dart';
import 'package:app/structures/models/subBuketModel.dart';
import 'package:app/system/keys.dart';
import 'package:app/tools/app/appBroadcast.dart';
import 'package:app/tools/app/appCache.dart';
import 'package:app/tools/app/appDb.dart';
import 'package:app/tools/app/appDialogIris.dart';
import 'package:app/tools/routeTools.dart';
import 'package:app/views/pages/levels/audio_player_page.dart';
import 'package:app/views/pages/levels/content_view_page.dart';
import 'package:app/views/pages/levels/video_player_page.dart';

class AdvertisingManager {
  AdvertisingManager._();
  
  static final List<AdvModel> _advList = [];
  static List<AdvModel> get advList => _advList;
  ///-----------------------------------------------------------------------------------------
  static DateTime? lastRequest;
  static Timer? timer;


  static void _onTimer() async {
    check();
  }

  static void init() async {
    timer ??= Timer(Duration(minutes: 30), _onTimer);

    EventNotifierService.addListener(AppEvents.networkConnected, _listener);

    if(lastRequest == null){
      requestAdvertising();
    }
  }

  static void _listener({data}) {
    check();
  }

  static void check() async {
    if(!AppCache.canCallMethodAgain('checkAdvertising')){
      return;
    }

    await Future.delayed(Duration(seconds: 8), (){}); // for avoid call fast after init
    if(lastRequest == null || DateHelper.isPastOf(lastRequest, Duration(minutes: 29))){
      requestAdvertising();
    }
  }

  /*static void _fetch(){
    final con = Conditions();

    final result = AppDB.db.query(AppDB.tbAdvertising, con);

    for(final k in result){
      AdvertisingManager.addItem(AdvModel.fromMap(k));
    }
  }*/

  static AdvModel? getById(int? id){
    try {
      return _advList.firstWhere((element) => element.id == id);
    }
    catch(e){
      return null;
    }
  }

  static AdvModel addItem(AdvModel item){
    final existItem = getById(item.id);
    item.mediaModel ??= MediaManager.getById(item.mediaId);

    if(existItem == null) {
      _advList.add(item);
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
    _advList.removeWhere((element) => element.id == id);
  }

  static void sortList(bool asc) async {
    _advList.sort((AdvModel p1, AdvModel p2){
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
    _advList.removeWhere((element) => !serverIds.contains(element.id));
  }

  static Future sinkAdv() async {
    final con = Conditions();

    for(final k in advList) {
      final val = k.toMap();
      con.clearConditions();
      con.add(Condition()..key = Keys.id..value = k.id);

      AppDB.db.insertOrReplace(AppDB.tbAdvertising, val, con);
    }
  }

  static Future requestAdvertising() async {
    final requester = Requester();

    requester.httpRequestEvents.onAnyState = (req) async {
      requester.dispose();
    };

    requester.httpRequestEvents.onStatusOk = (req, data) async {
      lastRequest = DateHelper.getNow();

      final advList = data['advertising_list'];
      final carouselList = data['carousel_list'];
      final mediaList = data['media_list'];

      MediaManager.addItemsFromMap(mediaList);
      MediaManager.sinkItems(MediaManager.mediaList);

      addItemsFromMap(advList);
      CarouselManager.addItemsFromMap(carouselList);

      AppBroadcast.newAdvNotifier.value++;
      //sinkAdv();
    };

    final js = <String, dynamic>{};
    js[Keys.requestZone] = 'get_advertising_data';

    requester.bodyJson = js;
    requester.prepareUrl();
    requester.request(null, false);
  }

  static bool hasAdv1(){
    return _advList.indexWhere((element) => element.tag == 'avd1') > -1;
  }

  static AdvModel? getAdv1(){
    try {
      return AdvertisingManager.advList.firstWhere((element) => element.tag == 'avd1');
    }
    catch (e){
      return null;
    }
  }

  static bool hasAdv2(){
    return _advList.indexWhere((element) => element.tag == 'avd2') > -1;
  }

  static AdvModel? getAdv2(){
    try {
      return AdvertisingManager.advList.firstWhere((element) => element.tag == 'avd2');
    }
    catch (e){
      return null;
    }
  }

  /*static bool hasAdv3(){
    return _list.indexWhere((element) => element.tag == 'avd3') > -1;
  }

  static AdvModel? getAdv3(){
    try {
      return AdvertisingManager.advList.firstWhere((element) => element.tag == 'avd3');
    }
    catch (e){
      return null;
    }
  }*/

  static void onAdvertisingClick(AdvModel adv){
    if(adv.clickUrl == null || adv.clickUrl!.isEmpty){
      return;
    }

    if(adv.type == 'url'){
      UrlHelper.launchWeb(adv.clickUrl!, mode: LaunchMode.externalApplication);
    }

    else if(adv.type == 'sub_bucket'){
      final sub = SubBucketModel.fromMap(JsonHelper.jsonToMap(adv.clickUrl)!);
      sub.mediaModel = MediaManager.getById(sub.mediaId);

      _onClickSubBucket(sub);
    }

    else if(adv.type == 'text'){
      AppDialogIris.instance.showIrisDialog(RouteTools.getTopContext()!,
          desc: adv.clickUrl!,
          yesText: 'بله'
      );
    }
  }

  static void _onClickSubBucket(SubBucketModel itm) {
    LastSeenService.addItem(itm);

    if(itm.type == SubBucketTypes.video.id()){
      final inject = VideoPlayerPageInjectData();
      inject.srcAddress = itm.mediaModel!.url!;
      inject.videoSourceType = VideoSourceType.network;

      RouteTools.pushPage(RouteTools.getTopContext()!, VideoPlayerPage(injectData: inject));
      return;
    }

    if(itm.type == SubBucketTypes.audio.id()){
      final inject = AudioPlayerPageInjectData();
      inject.srcAddress = itm.mediaModel!.url!;
      inject.audioSourceType = AudioSourceType.network;
      inject.title = '';//bucketModel?.title;
      inject.subTitle = itm.title;

      RouteTools.pushPage(RouteTools.getTopContext()!, AudioPlayerPage(injectData: inject));
      return;
    }

    if(itm.type == SubBucketTypes.list.id()){
      final inject = ContentViewPageInjectData();
      inject.subBucket = itm;

      RouteTools.pushPage(RouteTools.getTopContext()!, ContentViewPage(injectData: inject));
      return;
    }
  }
}
