import 'dart:async';

import 'package:dio/dio.dart';
import 'package:iris_tools/api/helpers/jsonHelper.dart';
import 'package:iris_tools/api/system.dart';
import 'package:iris_tools/models/two_state_return.dart';

import 'package:app/managers/settings_manager.dart';
import 'package:app/services/firebase_service.dart';
import 'package:app/services/session_service.dart';
import 'package:app/structures/middleWares/requester.dart';
import 'package:app/system/constants.dart';
import 'package:app/system/keys.dart';
import 'package:app/tools/device_info_tools.dart';
import 'package:app/tools/route_tools.dart';

class ApiManager {
  ApiManager._();

  static String get serverApi => '${SettingsManager.localSettings.httpAddress}/graph-v2';
  static String get logReportApi => '${SettingsManager.localSettings.httpAddress}/logs';
  static String fcmTopic = 'daily_text';

  static Future<TwoStateReturn<Map, Response>> publicApiCaller(String url, MethodType methodType, Map<String, dynamic>? body){
    Requester requester = Requester();
    Completer<TwoStateReturn<Map, Response>> res = Completer();

    requester.httpRequestEvents.onFailState = (req, response) async {
      res.complete(TwoStateReturn(r2: response));
      return true;
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

    requester.request();
    return res.future;
  }

  static Map<String, dynamic> getHeartMap() {
    final heart = <String, dynamic>{};
    heart['heart'] = 'heart';
    heart['app_name'] = Constants.appName;
    heart['app_version_code'] = Constants.appVersionCode;
    heart['app_version_name'] = Constants.appVersionName;
    heart['device_type'] = DeviceInfoTools.deviceType;
    heart['fcm_token'] = FireBaseService.token;
    heart[Keys.deviceId] = DeviceInfoTools.deviceId;

    if(RouteTools.materialContext != null) {
      heart[Keys.languageIso] = System.getLocalizationsLanguageCode(RouteTools.getTopContext()!);
    }
    else {
      heart[Keys.languageIso] = SettingsManager.localSettings.appLocale.languageCode;
    }

    final users = [];

    for(final um in SessionService.currentLoginList) {
      users.add(um.userId);
    }

    heart['users'] = users;

    return heart;
  }
}

