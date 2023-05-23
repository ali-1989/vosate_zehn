import 'dart:async';

import 'package:flutter/material.dart';

import 'package:dio/dio.dart';
import 'package:iris_tools/api/helpers/jsonHelper.dart';
import 'package:iris_tools/api/logger/logger.dart';
import 'package:iris_tools/api/logger/reporter.dart';
import 'package:iris_tools/api/system.dart';
import 'package:iris_tools/dateSection/dateHelper.dart';
import 'package:iris_tools/models/twoStateReturn.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import 'package:app/constants.dart';
import 'package:app/managers/settingsManager.dart';
import 'package:app/services/firebase_service.dart';
import 'package:app/structures/middleWares/requester.dart';
import 'package:app/structures/mixins/dateFieldMixin.dart';
import 'package:app/structures/models/upperLower.dart';
import 'package:app/structures/models/userModel.dart';
import 'package:app/system/keys.dart';
import 'package:app/services/session_service.dart';
import 'package:app/tools/deviceInfoTools.dart';
import 'package:app/tools/routeTools.dart';

class PublicAccess {
  PublicAccess._();

  static late Logger logger;
  static late Reporter reporter;
  static String graphApi = '${SettingsManager.settingsModel.httpAddress}/graph-v1';
  static String fcmTopic = 'daily_text';
  static ClassicFooter classicFooter = const ClassicFooter(
    loadingText: '',
    idleText: '',
    noDataText: '',
    failedText: '',
    loadStyle: LoadStyle.ShowWhenLoading,
  );

  static Map addLanguageIso(Map src, [BuildContext? ctx]) {
    src[Keys.languageIso] = System.getLocalizationsLanguageCode(ctx ?? RouteTools.getTopContext()!);

    return src;
  }

  static Map addAppInfo(Map src, {UserModel? curUser}) {
    final token = curUser?.token ?? SessionService.getLastLoginUser()?.token;

    src.addAll(getAppInfo());

    if (token?.token != null) {
      src[Keys.token] = token?.token;
      src['fcm_token'] = FireBaseService.token;
    }

    return src;
  }

  static Map<String, dynamic> getAppInfo() {
    final res = <String, dynamic>{};
    res[Keys.deviceId] = DeviceInfoTools.deviceId;
    res[Keys.appName] = Constants.appName;
    res['app_version_code'] = Constants.appVersionCode;
    res['app_version_name'] = Constants.appVersionName;

    return res;
  }

  static void sortList(List<DateFieldMixin> list, bool isAsc){
    if(list.isEmpty){
      return;
    }

    int sorter(DateFieldMixin d1, DateFieldMixin d2){
      return DateHelper.compareDates(d1.date, d2.date, asc: isAsc);
    }

    list.sort(sorter);
  }

  static Future<TwoStateReturn<Map, Response>> publicApiCaller(String url, MethodType methodType, Map<String, dynamic>? body){
    Requester requester = Requester();
    Completer<TwoStateReturn<Map, Response>> res = Completer();

    requester.httpRequestEvents.onFailState = (req, response) async {
      res.complete(TwoStateReturn(r2: response));
    };

    requester.httpRequestEvents.onStatusOk = (req, data) async {
      final js = JsonHelper.jsonToMap(data)!;

      res.complete(TwoStateReturn(r1: js));
    };

    if(body != null){
      requester.bodyJson = body;
    }

    requester.prepareUrl(pathUrl: url);
    requester.methodType = methodType;

    requester.request(null, false);
    return res.future;
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

  static Map<String, dynamic> getHeartMap() {
    final heart = <String, dynamic>{};
    heart['heart'] = 'heart';
    heart['app_name'] = Constants.appName;
    heart['app_version_code'] = Constants.appVersionCode;
    heart['app_version_name'] = Constants.appVersionName;
    heart['fcm_token'] = FireBaseService.token;
    heart[Keys.deviceId] = DeviceInfoTools.deviceId;

    if(RouteTools.materialContext != null) {
      heart[Keys.languageIso] = System.getLocalizationsLanguageCode(RouteTools.getTopContext()!);
    }
    else {
      heart[Keys.languageIso] = SettingsManager.settingsModel.appLocale.languageCode;
    }

    final users = [];

    for(var um in SessionService.currentLoginList) {
      users.add(um.userId);
    }

    heart['users'] = users;

    return heart;
  }
}

