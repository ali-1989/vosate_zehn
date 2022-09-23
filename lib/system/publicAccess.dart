import 'package:app/services/firebase_service.dart';
import 'package:flutter/material.dart';

import 'package:iris_tools/api/logger/logger.dart';
import 'package:iris_tools/api/logger/reporter.dart';
import 'package:iris_tools/api/system.dart';
import 'package:iris_tools/dateSection/dateHelper.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import 'package:app/constants.dart';
import 'package:app/managers/settingsManager.dart';
import 'package:app/models/mixin/dateFieldMixin.dart';
import 'package:app/models/userModel.dart';
import 'package:app/system/keys.dart';
import 'package:app/system/session.dart';
import 'package:app/tools/app/appRoute.dart';
import 'package:app/tools/deviceInfoTools.dart';

class PublicAccess {
  PublicAccess._();

  static late Logger logger;
  static late Reporter reporter;
  static String graphApi = '${SettingsManager.settingsModel.httpAddress}/graph-v1';
  static ClassicFooter classicFooter = ClassicFooter(
    loadingText: '',
    idleText: '',
    noDataText: '',
    failedText: '',
    loadStyle: LoadStyle.ShowWhenLoading,
  );

  static Map addLanguageIso(Map src, [BuildContext? ctx]) {
    src[Keys.languageIso] = System.getLocalizationsLanguageCode(ctx ?? AppRoute.getContext());

    return src;
  }

  static Map addAppInfo(Map src, {UserModel? curUser}) {
    final token = curUser?.token ?? Session.getLastLoginUser()?.token;

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

  static void sortList(List<DateFieldMixin> list, bool isAsc){
    if(list.isEmpty){
      return;
    }

    int sorter(DateFieldMixin d1, DateFieldMixin d2){
      return DateHelper.compareDates(d1.date, d2.date, asc: isAsc);
    }

    list.sort(sorter);
  }

  static Map<String, dynamic> getHeartMap() {
    final heart = <String, dynamic>{
      'heart': 'heart',
      Keys.deviceId: DeviceInfoTools.deviceId,
      Keys.languageIso: System.getLocalizationsLanguageCode(AppRoute.getContext()),
      'app_version_code': Constants.appVersionCode,
      'app_version_name': Constants.appVersionName,
      'app_name': Constants.appName,
      'fcm_token': FireBaseService.token,
    };

    final users = [];

    for(var um in Session.currentLoginList) {
      users.add(um.userId);
    }

    heart['users'] = users;

    return heart;
  }
}

///===================================================================================
class UpperLower {
  DateTime? upper;
  DateTime? lower;

  String? get upperAsTS => DateHelper.toTimestampNullable(upper);
  String? get lowerAsTS => DateHelper.toTimestampNullable(lower);
}
