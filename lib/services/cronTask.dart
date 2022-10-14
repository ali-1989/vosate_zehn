import 'package:app/system/initialize.dart';
import 'package:app/system/publicAccess.dart';
import 'package:app/tools/app/appNotification.dart';
import 'package:iris_tools/api/generator.dart';
import 'package:workmanager/workmanager.dart';

///--------------------------------------------------------------------------------------------
void callbackWorkManager() {
  Workmanager().executeTask((task, inputData) async {
    await InitialApplication.importantInit();
    PublicAccess.logger.logToAll('> ${DateTime.now()} |');

    await AppNotification.initial();

    AppNotification.sendNotification('worker', 'test', id: Generator.generateIntId(3));
    /*switch (task) {
      case Constants.appName:
        break;
      case Workmanager.iOSBackgroundTask:
        break;
    }*/

    return Future.value(true);
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
        'periodic-task-id',
        'periodic-task',
        frequency: Duration(hours: 1),
      initialDelay: Duration(milliseconds: 30),
      existingWorkPolicy: ExistingWorkPolicy.replace,
        backoffPolicy: BackoffPolicy.linear,
        constraints: Constraints(
            networkType: NetworkType.not_required,
            requiresBatteryNotLow: false,
          requiresCharging: false,
          requiresDeviceIdle: false,
        ),
    );
  }
}