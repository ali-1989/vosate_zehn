import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:iris_tools/dateSection/dateHelper.dart';
import 'package:workmanager/workmanager.dart';

import 'package:app/main.dart';
import 'package:app/services/native_call_service.dart';
import 'package:app/system/constants.dart';
import 'package:app/tools/app/app_notification.dart';
import 'package:app/tools/log_tools.dart';

@pragma('vm:entry-point')
Future<bool> _callbackWorkManager(task, inputData) async {
  try {
    WidgetsFlutterBinding.ensureInitialized();
    await prepareDirectoriesAndLogger();
    LogTools.logger.logToFile('work manager - A');
    NativeCallService.init();
    await AppNotification.initial();
    AppNotification.sendMessagesNotification('t1', 'ali', 't: ${DateHelper.now()}');

    var isAppRun = false;

    try {
      isAppRun = (await NativeCallService.assistanceBridge!.invokeMethod('isAppRun')).$1;
      LogTools.logger.logToFile('work manager B, isAppRun: $isAppRun');
    }
    catch (e) {
      LogTools.logger.logToFile('work manager, err: $e');
    }

    if (isAppRun) {
      return true;
    }

    /*switch (task) {
      case Workmanager.iOSBackgroundTask:
        break;
    }*/

    return true;
  }
  catch (e) {
    /// if return false, this method call again.(backoffPolicyDelay)
    return false;
  }
}

@pragma('vm:entry-point')
void callbackWorkManager() {
  Workmanager().executeTask(_callbackWorkManager);
}
///=============================================================================
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
      frequency: const Duration(minutes: 30),
      initialDelay: const Duration(milliseconds: 15),
      backoffPolicyDelay: const Duration(minutes: 16),
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
