import 'dart:ui';

import 'package:app/system/initialize.dart';
import 'package:app/system/publicAccess.dart';
import 'package:flutter/services.dart';


class JavaCallService {
  static MethodChannel? javaChannel;

  JavaCallService._();

  static void init() async {
    if(javaChannel == null) {
      javaChannel = MethodChannel('my_channel');
      javaChannel!.setMethodCallHandler(methodCallHandler);
    }

    setBootCallbackHandler();
  }

  static Future<void> setBootCallbackHandler() async {
    final callback = PluginUtilities.getCallbackHandle(bootCallbackHandler);

    if (callback != null) {
      final int handle = callback.toRawHandle();
      await invokeMethod('set_dart_handler', data: {'handle_id': handle});
    }
  }

  static Future<T?> invokeMethod<T>(String method, {Map? data}) async {
    if(javaChannel == null){
      init();
    }

    try {
      return javaChannel?.invokeMethod<T>(method, data);
    }
    catch (e){
      return null;
    }
  }
}
///===================================================================================
void bootCallbackHandler() async {
  try {
    await InitialApplication.importantInit();
    await PublicAccess.logger.logToAll('--->> appJavaCallback call ---');//todo
    /*await InitialApplication.launchUpInit();
    await InitialApplication.appLazyInit();

    JavaCallService.init();*/
  }
  catch (e){/**/}
}
///===================================================================================
Future methodCallHandler(MethodCall methodCall) async {
  try {
    return true;
  }
  catch (e){
    return false;
  }
}