import 'package:app/services/firebase_service.dart';
import 'package:app/system/initialize.dart';
import 'package:app/system/publicAccess.dart';
import 'package:app/tools/app/appBroadcast.dart';
import 'package:flutter/material.dart';
import 'package:workmanager/workmanager.dart';
import 'package:app/constants.dart';

///--------------------------------------------------------------------------------------------
void callbackWorkManager() {
  Workmanager().executeTask((task, inputData) async {
    try {
      WidgetsFlutterBinding.ensureInitialized();
      await InitialApplication.importantInit();
      PublicAccess.logger.logToAll('---callbackWorkManager---');//todo
      await InitialApplication.launchUpInit();
      InitialApplication.appLazyInit();

      await FireBaseService.init();
      await FireBaseService.getToken();
      FireBaseService.subscribeToTopic('daily_text');
      PublicAccess.logger.logToAll('---ws: ${AppBroadcast.isWsConnected}---');//todo
      /*switch (task) {
      case Workmanager.iOSBackgroundTask:
        break;
    }*/

      return true;
    }
    catch (e){
      return false;
    }
  });
}
///============================================================================================
class CronTask {
  CronTask._();

  static void init(){
    Workmanager().initialize(
      callbackWorkManager,
      isInDebugMode: false,
    );

    Workmanager().registerPeriodicTask(
        'WorkManager-task-${Constants.appName}',
        'periodic-${Constants.appName}',
        frequency: Duration(hours: 2),
      initialDelay: Duration(milliseconds: 20),
      backoffPolicyDelay: Duration(minutes: 20),
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