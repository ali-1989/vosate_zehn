import 'package:app/structures/enums/appEvents.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

import 'package:app/managers/advertisingManager.dart';
import 'package:app/managers/systemParameterManager.dart';

import 'package:app/tools/app/appBroadcast.dart';
import 'package:app/tools/app/appCache.dart';
import 'package:iris_notifier/iris_notifier.dart';

class NetListenerTools {
  NetListenerTools._();

  /// this fn call on app launch: if (wifi/cell data) is on. on Web not call
  static void onNetListener(ConnectivityResult connectivityResult) async {
    EventNotifierService.notify(AppEvents.networkStateChange);

    if(connectivityResult != ConnectivityResult.none) {
      AppBroadcast.isNetConnected = true;
      EventNotifierService.notify(AppEvents.networkConnected);
      //await ServerTimeTools.requestUtcTimeOfServer();
      SystemParameterManager.requestParameters();
      AdvertisingManager.check();
    }
    else {
      AppBroadcast.isNetConnected = false;
      EventNotifierService.notify(AppEvents.networkDisConnected);

      AppCache.clearDownloading();
    }
  }

  static void onWsConnectedListener(){
    AppBroadcast.isWsConnected = true;
    EventNotifierService.notify(AppEvents.webSocketStateChange);
    EventNotifierService.notify(AppEvents.webSocketConnected);
  }

  static void onWsDisConnectedListener(){
    AppBroadcast.isWsConnected = false;
    EventNotifierService.notify(AppEvents.webSocketDisConnected);
  }
}
