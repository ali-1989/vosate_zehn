import 'dart:async';

import 'package:app/main.dart';
import 'package:app/services/firebase_service.dart';
import 'package:app/tools/log_tools.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:workmanager/workmanager.dart';

import 'package:app/constants.dart';
import 'package:app/services/native_call_service.dart';

@pragma('vm:entry-point')
Future<bool> _callbackWorkManager(task, inputData) async {
  WidgetsFlutterBinding.ensureInitialized();
  await prepareDirectoriesAndLogger();
  NativeCallService.init();

  var isAppRun = false;

  try {
    isAppRun = (await NativeCallService.assistanceBridge!.invokeMethod('isAppRun')).$1;
    await LogTools.logger.logToAll('@@@@@@@@@: isAppRun: $isAppRun , ${DateTime.now()}'); //todo.
  }
  catch (e) {/**/}

  if (isAppRun) {
    return true;
  }

  try {
    /*switch (task) {
      case Workmanager.iOSBackgroundTask:
        break;
    }*/

    int count = 0;
    Timer? t;
    Completer c = Completer();

    t = Timer.periodic(Duration(minutes: 1), (timer) {
      if(count < 5){
        count++;
        LogTools.logger.logToAll('@@@@@@@@@: min: $count'); //todo.
      }
      else {
        t!.cancel();
        c.complete(null);
      }
    });

    FireBaseService.initializeApp();
    FireBaseService.start();
    await c.future;

    main();
    LogTools.logger.logToAll('@@@@@@@@@: main start'); //todo.
    return true;
  }
  catch (e) {
    return false;
  }
}

@pragma('vm:entry-point')
void callbackWorkManager() {
  Workmanager().executeTask(_callbackWorkManager);
}
///============================================================================================
class WakeupService {
  WakeupService._();

  static void init() {
    if(kIsWeb){
      return;
    }

    Workmanager().initialize(
      callbackWorkManager,
      isInDebugMode: false,
    );

    Workmanager().registerPeriodicTask(
      'WorkManager-task-${Constants.appName}',
      'periodic-${Constants.appName}',
      frequency: const Duration(hours: 1),
      initialDelay: const Duration(milliseconds: 30),
      backoffPolicyDelay: const Duration(minutes: 5),
      existingWorkPolicy: ExistingWorkPolicy.keep,
      backoffPolicy: BackoffPolicy.linear,
      constraints: Constraints(
        networkType: NetworkType.not_required,
        requiresBatteryNotLow: false,
        requiresCharging: false,
        requiresDeviceIdle: false,
        requiresStorageNotLow: false,
      ),
    );
  }
}
