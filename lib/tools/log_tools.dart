import 'dart:async';
import 'dart:developer';

import 'package:flutter/foundation.dart';

import 'package:http/http.dart' as http;
import 'package:iris_tools/api/generator.dart';
import 'package:iris_tools/api/helpers/jsonHelper.dart';
import 'package:iris_tools/api/logger/logger.dart';
import 'package:iris_tools/api/logger/reporter.dart';

import 'package:app/managers/api_manager.dart';
import 'package:app/services/session_service.dart';
import 'package:app/system/constants.dart';
import 'package:app/system/keys.dart';
import 'package:app/tools/app/app_cache.dart';
import 'package:app/tools/app/app_directories.dart';
import 'package:app/tools/device_info_tools.dart';

class LogTools {
  LogTools._();

  static late Logger logger;
  static late Reporter localReporter;
  static List avoidReportMessageList = <String>[];

  static Future<bool> init() async {
    try {
      if (kIsWeb) {
        LogTools.localReporter = Reporter('/', 'report');
      }
      else {
        LogTools.localReporter = Reporter(AppDirectories.getExternalAppFolder(), 'report');
      }

      LogTools.logger = Logger('${AppDirectories.getExternalTempDir()}/logs');

      avoidReportMessageList.add('\'hasSize\': RenderBox');
      avoidReportMessageList.add('has a negative minimum');
      avoidReportMessageList.add('slot == null');
      avoidReportMessageList.add('FIS_AUTH_ERROR'); // firebase
      avoidReportMessageList.add('RenderFlex overflowed by');
      avoidReportMessageList.add('RenderFlex children have non-zero flex');
      avoidReportMessageList.add('Could not navigate');

      return true;
    }
    catch (e){
      log('$e\n\n${StackTrace.current}');
      return false;
    }
  }

  static Map<String, dynamic> buildServerLog(String subject, {dynamic data, String? error}){
    final map = <String, dynamic>{};
    map['subject'] = subject;

    if(error != null) {
      map['error'] = error;
    }

    if(data != null) {
      map['data'] = data;
    }

    return map;
  }
  /// must map include a 'subject' key.
  static void reportLogToServer(Map<String, dynamic> map) async {
    final String? subjectKey = map['subject'];

    if(subjectKey == null){
      return;
    }

    final hash = Generator.hashMd5(subjectKey);

    if(!AppCache.canCallMethodAgain(hash)){
      return;
    }

    for(final x in avoidReportMessageList){
      if(subjectKey.contains(x)){
        return;
      }
    }

    void fn(){
      final url = Uri.parse(ApiManager.logReportApi);

      map['hash'] = hash;
      map['device_id'] = DeviceInfoTools.deviceId;
      map['user_id'] = SessionService.getLastLoginUser()?.userId;
      map['device_info'] = DeviceInfoTools.mapDeviceInfo();

      final body = <String, dynamic>{
        Keys.key: 'app_exception',
        'log_data': map,
        'user_id' : SessionService.getLastLoginUser()?.userId,
        'app_name': Constants.appName
      };


      final headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };

      http.post(url, body: JsonHelper.mapToJson(body), headers: headers);
    }


    runZonedGuarded(fn, (error, stack) {
      LogTools.logger.logToAll('::::::::::::: Reporting to Server is failed ::::::::::: ${error.toString()}');
    });
  }
}
