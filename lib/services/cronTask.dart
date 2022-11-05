import 'package:app/services/firebase_service.dart';
import 'package:app/services/javaCallService.dart';
import 'package:app/system/initialize.dart';
import 'package:app/system/publicAccess.dart';
import 'package:workmanager/workmanager.dart';
import 'package:app/constants.dart';

///--------------------------------------------------------------------------------------------
Future<bool> _callbackWorkManager(task, inputData) async {
  await InitialApplication.importantInit();
  //await PublicAccess.logger.logToAll('@@@@@@@@@@@@');//todo
  var isAppRun = false;

  try {
    /*Future.delayed(Duration(minutes: 2), () async{
      await PublicAccess.logger.logToAll('@@@@@@@@@@@@ delayed');//todo
    });*/

    final isAppRun = await JavaCallService.invokeMethod('isAppRun');
    //await PublicAccess.logger.logToAll('@@@@@@@@@@@@ isAppRun: $isAppRun'); //todo
  }
  catch (e) {}

  if (isAppRun) {
    return true;
  }
  //await PublicAccess.logger.logToAll('@@@@@@@@@ app is close');
  try {
    await FireBaseService.init();
    await InitialApplication.launchUpInit();
    await InitialApplication.appLazyInit();

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
    Workmanager().initialize(
      callbackWorkManager,
      isInDebugMode: false,
    );

    Workmanager().registerPeriodicTask(
      'WorkManager-task-${Constants.appName}',
      'periodic-${Constants.appName}',
      frequency: Duration(hours: 1),
      initialDelay: Duration(milliseconds: 20),
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
