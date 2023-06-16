import 'package:flutter/foundation.dart';

import 'package:workmanager/workmanager.dart';

import 'package:app/constants.dart';
import 'package:app/services/native_call_service.dart';

///--------------------------------------------------------------------------------------------
Future<bool> _callbackWorkManager(task, inputData) async {
  //await ApplicationInitial.prepareDirectoriesAndLogger();
  //await PublicAccess.logger.logToAll('@@@@@@@-@@@@@');//todo
  var isAppRun = false;

  try {
    isAppRun = await NativeCallService.invokeMethod('isAppRun');
    //await PublicAccess.logger.logToAll('@@@@@@@@@@@@ isAppRun: $isAppRun'); //todo
  }
  catch (e) {}

  if (isAppRun) {
    return true;
  }

  //await PublicAccess.logger.logToAll('@@@@@@@@@ app was closed'); //todo
  try {
    //await ApplicationInitial.inSplashInit();
    //await ApplicationInitial.appLazyInit();

    /*switch (task) {
      case Workmanager.iOSBackgroundTask:
        break;
    }*/

    return true;
  }
  catch (e) {
    return false;
  }
}

void callbackWorkManager() {
  Workmanager().executeTask(_callbackWorkManager);
}
///============================================================================================
class CronTask {
  CronTask._();

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
      frequency: Duration(hours: 3),
      initialDelay: Duration(milliseconds: 30),
      backoffPolicyDelay: Duration(minutes: 5),
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
