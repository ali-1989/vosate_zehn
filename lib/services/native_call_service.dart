import 'dart:ui';

import 'package:app/tools/log_tools.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'package:iris_tools/api/system.dart';

import 'package:app/system/applicationInitialize.dart';

class NativeCallService {
  static MethodChannel? nativeChannel;

  NativeCallService._();

  static void init() async {
    if(kIsWeb || !System.isAndroid()){
      return;
    }

    if(nativeChannel == null) {
      nativeChannel = MethodChannel('my_channel');
      nativeChannel!.setMethodCallHandler(methodCallHandler);
    }

    setBootCallbackHandler();
  }

  static Future<void> setBootCallbackHandler() async {
    if(kIsWeb || !System.isAndroid()){
      return;
    }

    final callback = PluginUtilities.getCallbackHandle(bootCallbackHandler);

    if (callback != null) {
      final int handle = callback.toRawHandle();
      await invokeMethod('set_dart_handler', data: {'handle_id': handle});
    }
  }

  static Future<T?> invokeMethod<T>(String method, {Map? data}) async {
    if(nativeChannel == null){
      init();
    }

    try {
      return nativeChannel?.invokeMethod<T>(method, data);
    }
    catch (e){
      return null;
    }
  }
}
///===================================================================================
@pragma('vm:entry-point')
void bootCallbackHandler() async {
  try {
    await ApplicationInitial.prepareDirectoriesAndLogger();
    await LogTools.logger.logToAll('--->> appJavaCallback call ---');//todo
    /*
    DartPluginRegistrant.ensureInitialized(); //must not calling in root isolate
    await InitialApplication.inSplashInit();
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
