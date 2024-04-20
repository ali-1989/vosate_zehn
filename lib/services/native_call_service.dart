import 'dart:async';

import 'package:flutter/material.dart';

import 'package:iris_tools/api/system.dart';
import 'package:iris_tools/plugins/javaBridge.dart';

import 'package:app/main.dart';
import 'package:app/services/firebase_service.dart';
import 'package:app/tools/app/app_notification.dart';
import 'package:app/tools/log_tools.dart';

@pragma('vm:entry-point')
Future onBridgeCall(call) async {
  WidgetsFlutterBinding.ensureInitialized();
  await prepareDirectoriesAndLogger();
  LogTools.logger.logToAll('========================================= native  yes');//dodo.
  await AppNotification.initial();
  AppNotification.sendMessagesNotification('native', 'ali', 'Thanks God- native ${call.method}');

  if(call.method == 'report_error') {
    LogTools.reportLogToServer(LogTools.buildServerLog('native_report', data: call.arguments));
  }
  else if(call.method == 'androidReceiverIsCall') {
    await FireBaseService.initializeApp();
    await FireBaseService.start();
  }

  return null;
}
///=============================================================================
@pragma('vm:entry-point')
class NativeCallService {
  static JavaBridge? androidAppBridge;
  static JavaBridge? assistanceBridge;

  NativeCallService._();

  static void init() async {
    if(System.isAndroid()){
      _initAndroid();
      _setBootCallbackHandler();
    }
  }

  static void _initAndroid(){
    if(androidAppBridge != null){
      return;
    }

    androidAppBridge = JavaBridge();
    assistanceBridge = JavaBridge();

    androidAppBridge!.init('my_android_channel', onBridgeCall);

    assistanceBridge!.init('assistance', (call) async {
      return null;
    });
  }

  static Future<void> _setBootCallbackHandler() async {
    /*final callback = PluginUtilities.getCallbackHandle(callbackHandler);

    if (callback != null) {
      final int handle = callback.toRawHandle();
      await invokeMethod('set_dart_handler', data: {'handle_id': handle});
    }*/
  }
}



/*
==== assistance:
echo
echo_arg
throw_error   'throw_error', [{'delay': 5000}]
set_kv
get_kv
setAppIsRun
isAppRun
dismiss_notification
move_app_to_back
 */
