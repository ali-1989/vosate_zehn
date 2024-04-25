import 'dart:async';

import 'package:flutter/material.dart';

import 'package:iris_tools/dateSection/dateHelper.dart';

import 'package:app/services/session_service.dart';
import 'package:app/structures/middleWares/requester.dart';
import 'package:app/structures/mixins/date_field_mixin.dart';
import 'package:app/structures/models/upperLower.dart';
import 'package:app/system/build_flavor.dart';
import 'package:app/system/keys.dart';
import 'package:app/tools/app/app_toast.dart';
import 'package:app/tools/route_tools.dart';
import 'package:app/views/pages/profile/buy_vip_plan_page.dart';
import 'package:app/views/pages/profile/cafe_bazar_page.dart';

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

  static Widget getPayPage(){
    if(BuildFlavor.isForBazar()){
      return const CafeBazarPage();
    }

    return const BuyVipPlanPage();
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

}

