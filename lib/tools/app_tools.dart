import 'dart:async';

import 'package:app/services/last_seen_service.dart';
import 'package:app/services/vip_service.dart';
import 'package:app/structures/enums/enums.dart';
import 'package:app/structures/models/bucketModel.dart';
import 'package:app/structures/models/subBuketModel.dart';
import 'package:app/views/pages/levels/audio_player_page.dart';
import 'package:app/views/pages/levels/multi_item_page.dart';
import 'package:app/views/pages/levels/video_player_page.dart';
import 'package:flutter/material.dart';

import 'package:iris_tools/dateSection/dateHelper.dart';

import 'package:app/services/session_service.dart';
import 'package:app/structures/middleWares/requester.dart';
import 'package:app/structures/mixins/date_field_mixin.dart';
import 'package:app/structures/models/upperLower.dart';
import 'package:app/system/keys.dart';
import 'package:app/tools/app/app_toast.dart';
import 'package:app/tools/route_tools.dart';

class AppTools {
  AppTools._();

  static void sortList(List<DateFieldMixin> list, bool isAsc){
    if(list.isEmpty){
      return;
    }

    int sorter(DateFieldMixin d1, DateFieldMixin d2){
      return DateHelper.compareDates(d1.date, d2.date, asc: isAsc);
    }

    list.sort(sorter);
  }

  static WidgetsBinding getAppWidgetsBinding() {
    return WidgetsBinding.instance;
  }

  static UpperLower findUpperLower(List<DateFieldMixin> list, bool isAsc){
    final res = UpperLower();

    if(list.isEmpty){
      return res;
    }

    DateTime lower = list[0].date!;
    DateTime upper = list[0].date!;

    for(final x in list){
      var c = DateHelper.compareDates(x.date, lower, asc: isAsc);

      if(c < 0){
        upper = x.date!;
      }

      c = DateHelper.compareDates(x.date, upper, asc: isAsc);

      if(c > 0){
        lower = x.date!;
      }
    }

    return UpperLower()..lower = lower..upper = upper;
  }

  static Future<void> requestProfileDataForVip() async {
    final requester = Requester();
    final retCom = Completer();
    final user = SessionService.getLastLoginUser();

    if(user == null || user.userId == '0'){
      return;
    }

    final js = <String, dynamic>{};
    js[Keys.request] = 'get_profile_data';
    js[Keys.requesterId] = user.userId;
    js[Keys.forUserId] = user.userId;


    requester.httpRequestEvents.onStatusOk = (req, data) async {
      await SessionService.newProfileData(data as Map<String, dynamic>);
      AppToast.showToast(RouteTools.materialContext!, 'دسترسی شما امکان پذیر شد.');
    };

    requester.httpRequestEvents.onAnyState = (req) async {
      await Future.delayed(const Duration(seconds: 1));
      requester.dispose();
      retCom.complete();
    };

    requester.bodyJson = js;
    requester.prepareUrl();
    requester.request();

    return retCom.future;
  }

  static void onItemClick2(BuildContext context, SubBucketModel itm) {
    if(itm.type == SubBucketTypes.video.id()){
      final inject = VideoPlayerPageInjectData();
      inject.srcAddress = itm.mediaModel!.url!;
      inject.videoSourceType = VideoSourceType.network;

      RouteTools.pushPage(context, VideoPlayerPage(injectData: inject));
      return;
    }

    if(itm.type == SubBucketTypes.audio.id()){
      final inject = AudioPlayerPageInjectData();
      inject.srcAddress = itm.mediaModel!.url!;
      inject.audioSourceType = AudioSourceType.network;
      inject.title = '';//widget.injectData.level1model?.title;
      inject.subTitle = itm.title;

      RouteTools.pushPage(context, AudioPlayerPage(injectData: inject));
      return;
    }

    if(itm.type == SubBucketTypes.list.id()){
      RouteTools.pushPage(context, MultiItemPage(subBucket: itm));
      return;
    }
  }

  static void onItemClick(BuildContext context, SubBucketModel itm, {BucketModel? bucketModel}) {
    final canContinue = VipService.checkVip(context, itm);

    if(!canContinue){
      return;
    }

    LastSeenService.addItem(itm);

    if(itm.type == SubBucketTypes.video.id()){
      final inject = VideoPlayerPageInjectData();
      inject.srcAddress = itm.mediaModel!.url!;
      inject.videoSourceType = VideoSourceType.network;

      RouteTools.pushPage(context, VideoPlayerPage(injectData: inject));
      return;
    }

    if(itm.type == SubBucketTypes.audio.id()){
      final inject = AudioPlayerPageInjectData();
      inject.srcAddress = itm.mediaModel!.url!;
      inject.audioSourceType = AudioSourceType.network;
      inject.title = bucketModel?.title;
      inject.subTitle = itm.title;

      RouteTools.pushPage(context, AudioPlayerPage(injectData: inject));
      return;
    }

    if(itm.type == SubBucketTypes.list.id()){
      RouteTools.pushPage(context, MultiItemPage(subBucket: itm));
      return;
    }
  }

}

