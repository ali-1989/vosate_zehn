import 'package:app/main.dart';
import 'package:app/tools/log_tools.dart';
import 'package:flutter/foundation.dart';

import 'package:workmanager/workmanager.dart';

import 'package:app/constants.dart';
import 'package:app/services/native_call_service.dart';

@pragma('vm:entry-point')
Future<bool> _callbackWorkManager(task, inputData) async {
  await prepareDirectoriesAndLogger();
  await LogTools.logger.logToAll('@@@@@@@-@@@@@ work manager');//todo.
  var isAppRun = false;

  try {
    isAppRun = (await NativeCallService.androidAppBridge!.invokeMethod('isAppRun')).$1;
    await LogTools.logger.logToAll('@@@@@@@@@@@@ isAppRun: $isAppRun'); //todo.
  }
  catch (e) {}

  if (isAppRun) {
    return true;
  }

  await LogTools.logger.logToAll('@@@@@@@@@ app was closed'); //todo.

  try {
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
      frequency: const Duration(hours: 4),
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
