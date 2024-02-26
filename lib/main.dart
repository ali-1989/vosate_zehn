import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:app/managers/splash_manager.dart';
import 'package:app/services/native_call_service.dart';
import 'package:app/system/constants.dart';
import 'package:app/tools/app/app_directories.dart';
import 'package:app/tools/log_tools.dart';
import 'package:app/views/baseComponents/error_page.dart';
import 'package:app/views/baseComponents/my_app.dart';

///================ call on any hot restart

void main(List<String>? args) {
  PlatformDispatcher.instance.onError = mainIsolateError;
  FlutterError.onError = onErrorCatch;

  void zoneFn() async {
    if (defaultTargetPlatform != TargetPlatform.linux && defaultTargetPlatform != TargetPlatform.windows) {
      WidgetsFlutterBinding.ensureInitialized();
      const some = String.fromEnvironment('SOME_VAR');

      print('@@@@@@@@@@@@');
      print(some);
      print(const String.fromEnvironment('SOME_VAR'));
    }

    final initOk = await prepareDirectoriesAndLogger();

    if(!initOk.$1){
      runApp(ErrorPage(errorLog: initOk.$2));
      return;
    }

    final before = await SplashManager.beforeRunApp();

    if(before != null){
      runApp(ErrorPage(errorLog: before.toString()));
      return;
    }

    SplashManager.baseInitial();
    runApp(MyApp());
  }

  //runZonedGuarded(zoneFn, zonedGuardedCatch);
  zoneFn();
}

@pragma('vm:entry-point')
void dartFunction() async {
  WidgetsFlutterBinding.ensureInitialized();
  await prepareDirectoriesAndLogger();
  NativeCallService.init();
}

@pragma('vm:entry-point')
Future<(bool, String?)> prepareDirectoriesAndLogger() async {
  try {
    await AppDirectories.prepareStoragePaths(Constants.appName);
    LogTools.init();

    return (true, null);
  }
  catch (e){
    return (false, '$e\n\n${StackTrace.current}');
  }
}
///=============================================================================
void onErrorCatch(FlutterErrorDetails errorDetails) {
  var txt = 'AN ERROR HAS OCCURRED:: ${errorDetails.exception.toString()}';

  if(!kIsWeb) {
    txt += '\n STACK TRACE:: ${errorDetails.stack}';
  }

  txt += '\n************************ [END CATCH]';

  LogTools.logger.logToAll(txt, isError: true);

  final eMap = <String, dynamic>{};
  eMap['catcher'] = 'mainIsolateError';
  eMap['error'] = txt;

  LogTools.reportError(eMap);
}
///=============================================================================
bool mainIsolateError(error, sTrace) {
  var txt = 'main-isolate CAUGHT AN ERROR:: ${error.toString()}';

  if(!(kDebugMode || kIsWeb)) {
    txt += '\n STACK TRACE:: $sTrace';
  }

  txt += '\n************************ [END MAIN-ISOLATE]';
  LogTools.logger.logToAll(txt, isError: true);

  final eMap = <String, dynamic>{};
  eMap['catcher'] = 'mainIsolateError';
  eMap['error'] = txt;

  LogTools.reportError(eMap);

  if(kDebugMode) {
    return false;
  }

  return true;
}
///=============================================================================
void zonedGuardedCatch(error, sTrace) {
  var txt = 'ZONED-GUARDED CAUGHT AN ERROR:: ${error.toString()}';

  if(!(kDebugMode || kIsWeb)) {
    txt += '\n STACK TRACE:: $sTrace';
  }

  txt += '\n************************ [END ZONED-GUARDED]';
  LogTools.logger.logToAll(txt, isError: true);

  final eMap = <String, dynamic>{};
  eMap['catcher'] = 'zonedGuardedCatch';
  eMap['error'] = txt;

  LogTools.reportError(eMap);

  if(kDebugMode) {
    throw error;
  }
}
