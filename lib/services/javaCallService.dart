import 'dart:ui';

import 'package:app/services/firebase_service.dart';
import 'package:app/system/initialize.dart';
import 'package:app/system/publicAccess.dart';
import 'package:flutter/services.dart';


class JavaCallService {
  static MethodChannel? javaChannel;

  JavaCallService._();

  static void init() async {
    if(javaChannel == null) {
      javaChannel = MethodChannel('my_channel');
      javaChannel!.setMethodCallHandler(appJavaHandler);
    }

    final callback = PluginUtilities.getCallbackHandle(appJavaCallback);

    if (callback != null) {
      final int handle = callback.toRawHandle();

      await javaChannel?.invokeMethod<void>(
        'set_dart_handler',
        {'handle_id': handle},
      );
    }
  }
}
///===================================================================================
void appJavaCallback() async {
  try {
    await InitialApplication.importantInit();
    await PublicAccess.logger.logToAll('--->> appJavaCallback call ---');//todo
    /*await InitialApplication.launchUpInit();
    InitialApplication.appLazyInit();

    await FireBaseService.init();
    await FireBaseService.getToken();
    FireBaseService.subscribeToTopic('daily_text');

    JavaCallService.init();*/
  }
  catch (e){/**/}
}

Future appJavaHandler(MethodCall methodCall) async {
  try {
    return true;
  }
  catch (e){
    return false;
  }
}