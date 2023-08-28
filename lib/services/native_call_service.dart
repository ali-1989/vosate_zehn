import 'dart:async';
import 'dart:ui';

import 'package:iris_tools/api/system.dart';

import 'package:app/tools/log_tools.dart';
import 'package:iris_tools/plugins/javaBridge.dart';


@pragma('vm:entry-point')
void callbackHandler() async {
  try {
    //await ApplicationInitial.prepareDirectoriesAndLogger();
    await LogTools.logger.logToAll('--->> appJavaCallback call ---');//todo.
    /*
    DartPluginRegistrant.ensureInitialized(); //must not calling in root isolate
    await InitialApplication.inSplashInit();
    await InitialApplication.appLazyInit();

    JavaCallService.init();*/
  }
  catch (e){/**/}
}

@pragma('vm:entry-point')
Future onBridgeCall(call) async {
  if(call.method == 'report_error') {
    LogTools.reportError(call.arguments);
  }
  else {
    print('::::::::::::::: ${call.method}');
  }

  return null;
}
///===================================================================================
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

    assistanceBridge!.invokeMethod('setAppIsRun');
  }

  static Future<void> _setBootCallbackHandler() async {
    final callback = PluginUtilities.getCallbackHandle(callbackHandler);

    if (callback != null) {
      //final int handle = callback.toRawHandle();
      //await invokeMethod('set_dart_handler', data: {'handle_id': handle});
    }
  }
}



/*
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
