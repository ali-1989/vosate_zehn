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
import 'package:app/tools/route_tools.dart';

class LogTools {
  LogTools._();

  static late Logger _logger;
  static late Reporter localReporter;
  static final List avoidSendMessageList = <String>[];
  static final List avoidLocalLogMessageList = <String>[];

  static Future<bool> init() async {
    try {
      if (kIsWeb) {
        LogTools.localReporter = Reporter('/', 'report');
      }
      else {
        LogTools.localReporter = Reporter(AppDirectories.getExternalAppFolder(), 'report');
      }

      LogTools._logger = Logger('${AppDirectories.getExternalTempDir()}/logs');

      avoidSendMessageList.add('\'hasSize\': RenderBox');
      avoidSendMessageList.add('has a negative minimum');
      avoidSendMessageList.add('slot == null');
      avoidSendMessageList.add('FIS_AUTH_ERROR'); // firebase
      avoidSendMessageList.add('RenderFlex overflowed by');
      avoidSendMessageList.add('RenderFlex children have non-zero flex');
      avoidSendMessageList.add('Could not navigate');

      return true;
    }
    catch (e){
      log('$e\n\n${StackTrace.current}');
      return false;
    }
  }

  static void logToAll(String text, {String prefix = '', bool isError = false}){
    for(final x in avoidLocalLogMessageList){
      if(text.contains(x)){
        return;
      }
    }

    _logger.logToAll(text, type: prefix, isError: isError);
  }

  static void logToFile(String text, {String prefix = ''}){
    for(final x in avoidLocalLogMessageList){
      if(text.contains(x)){
        return;
      }
    }

    _logger.logToFile(text, type: prefix);
  }

  static void logToScreen(String text, {String prefix = ''}){
    /*for(final x in avoidLocalLogMessageList){
      if(text.contains(x)){
        return;
      }
    }*/

    _logger.logToScreen(text, type: prefix);
  }

  static Map<String, dynamic> buildServerLog(String subject, {dynamic data, String? error}){
    final map = <String, dynamic>{};
    map['SUBJECT'] = subject;

    if(error != null) {
      map['ERROR'] = error;
    }

    if(data != null) {
      map['DATA'] = data;
    }

    return map;
  }

  /// must map include a 'subject' key.
  static void reportLogToServer(Map<String, dynamic> map) async {
    final String? subjectKey = map['SUBJECT'];

    if(subjectKey == null){
      return;
    }

    final hash = Generator.hashMd5(subjectKey);

    if(!AppCache.canCallMethodAgain(hash)){
      return;
    }

    for(final x in avoidSendMessageList){
      if(subjectKey.contains(x)){
        return;
      }
    }

    void fn(){
      map['device_id'] = DeviceInfoTools.deviceId;
      map['user_id'] = SessionService.getLastLoginUser()?.userId;
      map['route_stack'] = RouteTools.oneNavigator.currentRoutes().map((e) => e.name).toList();
      map['device_info'] = DeviceInfoTools.mapDeviceInfo();
      map['hash'] = hash;

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

      final url = Uri.parse(ApiManager.logReportApi);
      http.post(url, body: JsonHelper.mapToJson(body), headers: headers);
    }


    runZonedGuarded(fn, (error, stack) {
      LogTools._logger.logToAll('::::::::::::: Reporting to Server is failed ::::::::::: ${error.toString()}');
    });
  }
}
