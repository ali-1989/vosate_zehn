import 'package:app/services/firebase_service.dart';
import 'package:app/system/initialize.dart';
import 'package:app/system/publicAccess.dart';
import 'package:workmanager/workmanager.dart';
import 'package:app/constants.dart';

///--------------------------------------------------------------------------------------------
void callbackWorkManager() {
  Workmanager().executeTask((task, inputData) async {
    try {
      await InitialApplication.importantInit();
      await InitialApplication.launchUpInit();
      InitialApplication.appLazyInit();

      await FireBaseService.init();
      await FireBaseService.getToken();
      FireBaseService.subscribeToTopic(PublicAccess.fcmTopic);

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