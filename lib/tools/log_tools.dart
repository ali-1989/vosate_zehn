import 'dart:async';
import 'dart:developer';

import 'package:app/system/constants.dart';
import 'package:app/system/keys.dart';
import 'package:app/tools/app/app_cache.dart';
import 'package:flutter/foundation.dart';

import 'package:http/http.dart' as http;
import 'package:iris_tools/api/generator.dart';
import 'package:iris_tools/api/helpers/jsonHelper.dart';
import 'package:iris_tools/api/logger/logger.dart';
import 'package:iris_tools/api/logger/reporter.dart';

import 'package:app/managers/api_manager.dart';
import 'package:app/services/session_service.dart';
import 'package:app/tools/app/app_directories.dart';
import 'package:app/tools/device_info_tools.dart';

class LogTools {
  LogTools._();

  static late Logger logger;
  static late Reporter reporter;
  static List avoidReport = <String>[];

  static Future<bool> init() async {
    try {
      if (kIsWeb) {
        LogTools.reporter = Reporter('/', 'report');
      }
      else {
        LogTools.reporter = Reporter(AppDirectories.getExternalAppFolder(), 'report');
      }

      LogTools.logger = Logger('${AppDirectories.getExternalTempDir()}/logs');

      avoidReport.add('\'hasSize\': RenderBox');
      avoidReport.add('has a negative minimum');
      avoidReport.add('slot == null');
      avoidReport.add('FIS_AUTH_ERROR'); // firebase
      avoidReport.add('RenderFlex overflowed by');
      avoidReport.add('RenderFlex children have non-zero flex');
      avoidReport.add('Could not navigate');

      return true;
    }
    catch (e){
      log('$e\n\n${StackTrace.current}');
      return false;
    }
  }

  static void reportError(Map<String, dynamic> map) async {
    final String txt = map['error']?? '';
    final hash = Generator.hashMd5(txt);

    if(!AppCache.canCallMethodAgain(hash)){
      return;
    }

    for(final x in avoidReport){
      if(txt.contains(x)){
        return;
      }
    }

    void fn(){
      final url = Uri.parse(ApiManager.logReportApi);

      final data = <String, dynamic>{};
      data['deviceId'] = DeviceInfoTools.deviceId;
      data['user_id'] = SessionService.getLastLoginUser()?.userId;
      //data['code'] = hash;
      data['info'] = DeviceInfoTools.mapDeviceInfo();
      data['log'] = map;

      final body = <String, dynamic>{
        Keys.key: 'app_exception',
        'data': data,
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
      LogTools.logger.logToAll('::::::::::::: report is failed ::::::::::: ${error.toString()}');
    });
  }
}
